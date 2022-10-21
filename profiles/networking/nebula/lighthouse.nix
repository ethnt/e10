{ config, lib, ... }: {
  services.nebula.networks.camp = {
    isLighthouse = lib.mkOverride 10 true;
    lighthouses = lib.mkOverride 10 [ ];
    settings = {
      lighthouse = {
        serve_dns = false;
        dns = {
          host = "0.0.0.0";
          port = 53;
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
