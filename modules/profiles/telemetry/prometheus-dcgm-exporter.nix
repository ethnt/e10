{ config, ... }: {
  services.prometheus.exporters.dcgm-exporter = {
    enable = true;
    openFirewall = true;
  };

  provides.prometheus-dcgm-exporter = {
    name = "Prometheus DCGM Exporter";
    http.port = config.services.prometheus.exporters.dcgm-exporter.port;
    monitor.enable = true;
  };
}
