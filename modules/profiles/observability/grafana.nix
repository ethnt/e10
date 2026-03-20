{ config, pkgs, ... }: {
  services.grafana = {
    enable = true;

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
      grafana-clock-panel
    ];

    settings = {
      server = {
        http_port = 2342;
        http_addr = "0.0.0.0";
      };

      panels = {
        enable_alpha = "true";
        disable_sanitize_html = "true";
      };
    };
  };

  provides.grafana = {
    name = "Grafana";
    http = {
      port = config.services.grafana.settings.server.http_port;
      proxy = {
        enable = true;
        domain = "grafana.e10.camp";
      };
    };
  };
}
