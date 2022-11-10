{
  services.prometheus.exporters.nginx = {
    enable = true;
    openFirewall = true;
  };
}
