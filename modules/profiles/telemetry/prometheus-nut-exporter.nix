{
  services.prometheus.exporters.nut = {
    enable = true;
    openFirewall = true;
    extraFlags = [ "--nut.vars_enable=''" ];
  };
}
