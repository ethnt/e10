{ hosts, ... }: {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "gateway";
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
        job_name = "monitor";
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
        job_name = "htpc";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.e10.privateAddress}:${
              toString hosts.htpc.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "matrix";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.e10.privateAddress}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "blocky";
        static_configs = [{ targets = [ "dns.e10.network" ]; }];
      }
      {
        job_name = "apcups";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.e10.privateAddress}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.apcupsd.port
            }"
          ];
        }];
      }
      {
        job_name = "nginx_gateway";
        static_configs = [{
          targets = [
            "${hosts.gateway.config.e10.privateAddress}:${
              toString
              hosts.gateway.config.services.prometheus.exporters.nginx.port
            }"
          ];
        }];
      }
      {
        job_name = "nginx_monitor";
        static_configs = [{
          targets = [
            "${hosts.monitor.config.e10.privateAddress}:${
              toString
              hosts.monitor.config.services.prometheus.exporters.nginx.port
            }"
          ];
        }];
      }
      {
        job_name = "htpc_gpu";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.e10.privateAddress}:${
              toString
              hosts.monitor.config.services.prometheus-exporters-intel-gpu.port
            }"
          ];
        }];
      }

    ];
  };
}
