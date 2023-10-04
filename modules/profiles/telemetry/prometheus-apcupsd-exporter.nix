{
  services.prometheus.exporters.apcupsd = {
    enable = true;
    openFirewall = true;
  };
}
