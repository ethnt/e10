{
  services.prometheus.exporters.nginx = {
    enable = true;
    sslVerify = false;
    openFirewall = true;
  };
}
