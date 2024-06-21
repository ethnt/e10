{
  services.prometheus.exporters.redis = {
    enable = true;
    openFirewall = true;
  };
}
