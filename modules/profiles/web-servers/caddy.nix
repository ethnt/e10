{
  services.caddy = {
    enable = true;
    globalConfig = ''
      # Admin is required to be on so Nix can reload the configuration instead of restart the whole process
      admin localhost:2019
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
