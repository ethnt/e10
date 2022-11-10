{ config, pkgs, ... }: {
  services.grafana = {
    enable = true;
    domain = "localhost";
    port = 2342;
    addr = "127.0.0.1";

    declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];

    extraOptions = {
      PANELS_ENABLE_ALPHA = "true";
      PANELS_DISABLE_SANITIZE_HTML = "true";
    };

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
        # {
        #   name = "PostgreSQL (Blocky, Public)";
        #   type = "postgresql";
        #   access = "proxy";
        #   url = "http://0.0.0.0:${
        #       toString
        #       config.services.loki.configuration.server.http_listen_port
        #     }";
        # }
      ];
      dashboards = [
        {
          name = "Nodes";
          options.path = ./dashboards/nodes.json;
        }
        {
          name = "APC UPS";
          options.path = ./dashboards/apcupsd.json;
        }
      ];
    };
  };

  services.nginx.virtualHosts = {
    "grafana.e10.network" = {
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
