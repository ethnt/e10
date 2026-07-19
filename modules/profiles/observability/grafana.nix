{ pkgs, ... }: {
  services.grafana = {
    enable = true;

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-clock-panel
      grafana-mqtt-datasource
      grafana-piechart-panel
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
}
