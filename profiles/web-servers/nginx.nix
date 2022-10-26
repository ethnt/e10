{
  services.nginx.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "camper@camp.computer";
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
