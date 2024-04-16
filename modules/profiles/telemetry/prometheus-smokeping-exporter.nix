{
  services.prometheus.exporters.smokeping = {
    enable = true;
    openFirewall = true;
    hosts = [ "1.1.1.1" "192.168.1.1" ];
  };
}
