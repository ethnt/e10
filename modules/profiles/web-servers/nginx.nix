{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    package = pkgs.nginx.override {
      modules = with pkgs.nginxModules; [ fancyindex develkit set-misc ];
    };
    statusPage = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@e10.camp";
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
