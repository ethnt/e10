{ inputs, config, lib, pkgs, profiles, suites, hosts, ... }: {
  imports = with suites;
    core ++ web ++ [
      profiles.virtualisation.aws
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

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node_gateway";
      static_configs = [{
        targets = [
          "${hosts.gateway.config.e10.privateAddress}:${
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
          "${hosts.monitor.config.e10.privateAddress}:${
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
          "${hosts.omnibus.config.e10.privateAddress}:${
            toString
            hosts.omnibus.config.services.prometheus.exporters.node.port
          }"
        ];
      }];
    }
    {
      job_name = "smartctl_omnibus";
      static_configs = [{
        targets = [
          "${hosts.omnibus.config.e10.privateAddress}:${
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
          "${hosts.omnibus.config.e10.privateAddress}:${
            toString hosts.omnibus.config.services.prometheus.exporters.zfs.port
          }"
        ];
      }];
    }
  ];

  system.stateVersion = "23.11";
}
