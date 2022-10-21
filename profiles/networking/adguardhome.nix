{ config, ... }: {
  services.adguardhome = {
    enable = true;
    mutableSettings = true;
  };

  networking.firewall = {
    allowedTCPPorts = [ config.services.adguardhome.port 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
