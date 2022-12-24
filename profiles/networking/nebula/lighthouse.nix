{ config, lib, ... }: {
  services.nebula.networks.e10 = {
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
      relay = {
        am_relay = true;
        relays = lib.mkOverride 10 [ ];
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
