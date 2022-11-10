{ pkgs, ... }: {
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
  };

  networking.firewall = {
    allowedTCPPorts = [ 8443 ];
    allowedUDPPorts = [ 8443 ];
  };
}
