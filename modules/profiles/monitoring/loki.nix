{ config, ... }: {
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = { http_listen_port = 3100; };
      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore = { store = "inmemory"; };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h";
        max_chunk_age = "24h";
        chunk_target_size = 1048576;
        chunk_retain_period = "30s";
      };
      schema_config = {
        configs = [{
          from = "2024-04-20";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
      compactor = { working_directory = "/var/lib/loki/compactor"; };
      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb/index";
          cache_location = "/var/lib/loki/tsdb/cache";
        };
        filesystem = { directory = "/var/lib/loki/chunks"; };
      };
      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
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

  networking.firewall = {
    allowedTCPPorts =
      [ config.services.loki.configuration.server.http_listen_port ];
    allowedUDPPorts =
      [ config.services.loki.configuration.server.http_listen_port ];
  };
}
