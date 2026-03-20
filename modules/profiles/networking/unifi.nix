{ pkgs, lib, ... }: {
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-ce-6_0;
  };

  # Set to 5 mintues by the NixOS module, but prevents shutdown of the host for
  # that long. Shorten to make this happen quicker
  systemd.services.unifi.serviceConfig.TimeoutSec = lib.mkOverride 10 "30s";

  networking.firewall = {
    allowedTCPPorts = [ 6789 8080 8880 8443 8843 ];
    allowedUDPPorts = [ 8443 ];
  };

  provides.unifi = {
    name = "UniFi Controller";
    http = {
      enable = true;
      port = 8443;
      domain = "unifi.satan.network";
      skipTLSVerify = true;
    };
  };
}
