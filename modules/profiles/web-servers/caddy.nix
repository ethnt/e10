{ config, ... }: {
  services.caddy = {
    enable = true;
    globalConfig = ''
      # Admin is required to be on so Nix can reload the configuration instead of restart the whole process
      admin ${config.e10.privateAddress}:2019
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
