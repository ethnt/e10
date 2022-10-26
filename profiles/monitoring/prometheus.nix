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
        job_name = "matrix";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.camp.privateAddress}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "blocky";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.camp.privateAddress}:${
              toString hosts.matrix.config.services.blocky.settings.httpPort
            }"
          ];
        }];
      }
      {
        job_name = "apcups";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.camp.privateAddress}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.apcupsd.port
            }"
          ];
        }];
      }
    ];
  };
}
