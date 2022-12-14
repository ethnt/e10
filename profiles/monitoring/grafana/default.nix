{ config, pkgs, ... }: {
  services.grafana = {
    enable = true;

    declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];

    settings = {
      server = {
        domain = "localhost";
        http_port = 2342;
        http_addr = "127.0.0.1";
      };

      panels = {
        enable_alpha = "true";
        disable_sanitize_html = "true";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
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
      dashboards.settings.providers = [
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
        proxyPass =
          "http://${config.services.grafana.settings.server.http_addr}:${
            toString config.services.grafana.settings.server.http_port
          }";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
        proxyWebsockets = true;
      };
    };
  };
}
