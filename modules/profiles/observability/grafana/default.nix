{ config, pkgs, hosts, ... }: {
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
        {
          name = "PostgreSQL (Blocky)";
          type = "postgres";
          access = "proxy";
          url = hosts.controller.config.networking.hostName;
          user = "blocky";
          secureJsonData = { password = "blocky"; };
          jsonData = {
            user = "blocky";
            database = "blocky";
            sslmode = "disable";
          };
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Nodes";
          options.path = ./provisioning/nodes.json;
        }
        {
          name = "systemd Service Dashboard";
          options.path = ./provisioning/systemd.json;
        }
      ];
    };
  };
}
