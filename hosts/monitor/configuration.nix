{ inputs, config, lib, pkgs, profiles, suites, hosts, ... }: {
  imports = with suites;
    core ++ web ++ aws ++ [
      profiles.monitoring.loki
      profiles.monitoring.prometheus
      profiles.observability.grafana.default
    ];

  e10 = {
    name = "monitor";
    privateAddress = "100.122.170.88";
    publicAddress = "3.129.217.133";
    domain = "monitor.e10.camp";
  };

  services.nginx.virtualHosts = {
    "grafana.e10.camp" = {
      http2 = true;
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass =
          "http://${config.services.grafana.settings.server.http_addr}:${
            toString config.services.grafana.settings.server.http_port
          }";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "host_anise";
      static_configs = [{ targets = [ "anise:9100" ]; }];
    }
    {
      job_name = "host_basil";
      static_configs = [{ targets = [ "basil:9100" ]; }];
    }
    {
      job_name = "node_gateway";
      static_configs = [{
        targets = [
          "${hosts.gateway.config.networking.hostName}:${
            toString
            hosts.gateway.config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }
    {
      job_name = "node_monitor";
      static_configs = [{
        targets = [
          "${hosts.monitor.config.networking.hostName}:${
            toString
            hosts.monitor.config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }
    {
      job_name = "node_omnibus";
      static_configs = [{
        targets = [
          "${hosts.omnibus.config.networking.hostName}:${
            toString
            hosts.omnibus.config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }
    {
      job_name = "node_htpc";
      static_configs = [{
        targets = [
          "${hosts.htpc.config.networking.hostName}:${
            toString hosts.htpc.config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }

    {
      job_name = "smartctl_omnibus";
      static_configs = [{
        targets = [
          "${hosts.omnibus.config.networking.hostName}:${
            toString
            hosts.omnibus.config.services.prometheus.exporters.smartctl.port
          }"
        ];
      }];
    }
    {
      job_name = "zfs_omnibus";
      static_configs = [{
        targets = [
          "${hosts.omnibus.config.networking.hostName}:${
            toString hosts.omnibus.config.services.prometheus.exporters.zfs.port
          }"
        ];
      }];
    }
  ];

  e10.backup.jobs.system.exclude = lib.mkAfter [ "/var/lib/loki/wal" ];

  system.stateVersion = "23.11";
}
