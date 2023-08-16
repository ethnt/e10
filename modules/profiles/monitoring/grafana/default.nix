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
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://0.0.0.0:${toString config.services.prometheus.port}";
      }];
      dashboards.settings.providers = [{
        name = "Nodes";
        options.path = ./provisioning/nodes.json;
      }];
    };
  };

  services.caddy.virtualHosts."grafana.e10.camp" = {
    extraConfig = ''
      handle {
        reverse_proxy ${config.services.grafana.settings.server.http_addr}:${
          toString config.services.grafana.settings.server.http_port
        }
      }
    '';
  };
}
