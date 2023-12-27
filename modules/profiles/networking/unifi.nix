{ pkgs, ... }: {
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi8;
  };

  networking.firewall = {
    allowedTCPPorts = [ 6789 8080 8880 8443 8843 ];
    allowedUDPPorts = [ 8443 ];
  };
}
