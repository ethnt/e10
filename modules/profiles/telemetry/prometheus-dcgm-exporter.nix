{
  services.prometheus.exporters.dcgm-exporter = {
    enable = true;
    openFirewall = true;
  };
}
