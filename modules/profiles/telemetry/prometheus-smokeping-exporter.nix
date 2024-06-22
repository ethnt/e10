{
  services.prometheus.exporters.smokeping = {
    enable = true;
    openFirewall = true;
    hosts = [ "1.1.1.1" ];
  };
}
