{ config, ... }: {
  sops = {
    secrets = {
      loki_aws_access_key_id = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      loki_aws_secret_access_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };
    };

    templates.loki_environment_file = {
      content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder.loki_aws_access_key_id}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.loki_aws_secret_access_key}
      '';
      mode = "0777";
      owner = "loki";
      restartUnits = [ "loki.service" ];
    };
  };

  services.loki = {
    enable = true;
    extraFlags = [ "-config.expand-env=true" "-log.level=warn" ];
    configuration = {
      auth_enabled = false;
      server = { http_listen_port = 3100; };
      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore = { store = "memberlist"; };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        shutdown_marker_path = "/tmp/loki-ingester-shutdown";
        chunk_idle_period = "1h";
        max_chunk_age = "24h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
      };
      schema_config = {
        configs = [
          {
            from = "2024-04-20";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
          {
            from = "2024-07-09";
            store = "tsdb";
            object_store = "aws";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
      compactor = { working_directory = "/var/lib/loki/compactor"; };
      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb/index";
          cache_location = "/var/lib/loki/tsdb/cache";
        };
        filesystem = { directory = "/var/lib/loki/chunks"; };
        aws = {
          s3 =
            "s3://\${AWS_ACCESS_KEY_ID}:\${AWS_SECRET_ACCESS_KEY}@us-east-2/storage.loki.e10.camp";
        };
      };
      memberlist = {
        bind_addr = [ "0.0.0.0" ];
        bind_port = 7946;
      };
      limits_config = {
        shard_streams = {
          enabled = true;
          desired_rate = 2097152; # 2MiB
        };
        cardinality_limit = 200000;
        ingestion_burst_size_mb = 2048;
        ingestion_rate_mb = 1024;
        ingestion_rate_strategy = "local";
        max_entries_limit_per_query = 1000000;
        max_label_name_length = 10240;
        max_label_names_per_series = 300;
        max_label_value_length = 40960;
        per_stream_rate_limit = "1G";
        per_stream_rate_limit_burst = "2G";
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        max_global_streams_per_user = 10000;
        max_streams_per_user = 0;
      };
      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
      ruler = {
        storage = {
          type = "local";
          local.directory = "/var/lib/loki/rules";
        };
        rule_path = "/tmp/loki/rules";
        ring.kvstore.store = "inmemory";
      };
    };
  };

  systemd.services.loki = {
    serviceConfig.EnvironmentFile =
      config.sops.templates.loki_environment_file.path;
    wants = [ "sops-nix.service" ];
    after = [ "sops-nix.service" ];
  };

  networking.firewall = {
    allowedTCPPorts =
      [ config.services.loki.configuration.server.http_listen_port ];
    allowedUDPPorts =
      [ config.services.loki.configuration.server.http_listen_port ];
  };

  services.borgmatic.configurations.system.exclude_patterns =
    [ "/var/lib/prometheus2/data/wal" ];
}
