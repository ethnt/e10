{ hosts, ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "gateway";
        static_configs = [{
          targets = [
            "${hosts.gateway.config.camp.privateAddress}:${
              toString
              hosts.gateway.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "monitor";
        static_configs = [{
          targets = [
            "${hosts.monitor.config.camp.privateAddress}:${
              toString
              hosts.monitor.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "errata";
        static_configs = [{
          targets = [
            "${hosts.errata.config.camp.privateAddress}:${
              toString
              hosts.errata.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "blocky_public";
        static_configs = [{
          targets = [
            "${hosts.gateway.config.camp.privateAddress}:${
              toString hosts.gateway.config.services.blocky.settings.httpPort
            }"
          ];
        }];
      }
      {
        job_name = "blocky_private";
        static_configs = [{
          targets = [
            "${hosts.errata.config.camp.privateAddress}:${
              toString hosts.errata.config.services.blocky.settings.httpPort
            }"
          ];
        }];
      }
    ];
  };
}
