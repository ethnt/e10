{ config, hosts, ... }: {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };

      positions.filename = "/tmp/positions.yml";

      clients = [{
        url = "http://${hosts.monitor.config.e10.privateAddress}:${
            toString
            hosts.monitor.config.services.loki.configuration.server.http_listen_port
          }/loki/api/v1/push";
      }];

      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            host = "host_${config.networking.hostName}";
            job = "systemd-journal";
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };
}
