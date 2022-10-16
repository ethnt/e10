{ config, ... }: {
  services.grafana = {
    enable = true;
    domain = "localhost";
    port = 2342;
    addr = "127.0.0.1";

    provision = {
      enable = true;
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://0.0.0.0:${toString config.services.prometheus.port}";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://0.0.0.0:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }";
        }
      ];
      dashboards = [{
        name = "Nodes";
        options.path = ./dashboards/nodes.json;
      }];
    };
  };

  services.nginx.virtualHosts = {
    "grafana.camp.computer" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${config.services.grafana.addr}:${
            toString config.services.grafana.port
          }";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
        proxyWebsockets = true;
      };
    };
  };
}
