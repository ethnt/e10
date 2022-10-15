{ config, ... }: {
  imports = [ ./map.nix ];

  services.nebula.networks.camp = {
    enable = true;
    lighthouses = [ config.networkMap.gateway.privateAddress ];
    isLighthouse = false;
    staticHostMap = {
      "${config.networkMap.gateway.privateAddress}" =
        [ config.networkMap.gateway.publicAddress ];
    };
    firewall = {
      inbound = [{
        host = "any";
        port = "any";
        proto = "any";
      }];
      outbound = [{
        host = "any";
        port = "any";
        proto = "any";
      }];
    };
  };

  networking.firewall.allowedUDPPorts = [ 4242 ];
}
