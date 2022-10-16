{ config, hosts, ... }: {
  sops.secrets = { nebula_ca_cert = { sopsFile = ./secrets.yaml; }; };

  services.nebula.networks.camp = {
    enable = true;
    ca = config.sops.secrets.nebula_ca_cert.path;
    lighthouses = [ hosts.gateway.config.camp.privateAddress ];
    isLighthouse = false;
    staticHostMap = {
      "${hosts.gateway.config.camp.privateAddress}" = [
        "${hosts.gateway.config.camp.publicAddress}:${
          toString
          hosts.gateway.config.services.nebula.networks.camp.listen.port
        }"
      ];
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
