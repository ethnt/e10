{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    package =
      pkgs.nginx.override { modules = [ pkgs.nginxModules.fancyindex ]; };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "camper@camp.computer";
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
