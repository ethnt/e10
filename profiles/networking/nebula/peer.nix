{ config, hosts, ... }: {
  sops.secrets = { nebula_ca_cert = { sopsFile = ./secrets.yaml; }; };

  services.nebula.networks.e10 = {
    enable = true;
    ca = config.sops.secrets.nebula_ca_cert.path;
    lighthouses = [ hosts.gateway.config.e10.privateAddress ];
    isLighthouse = false;
    staticHostMap = {
      "${hosts.gateway.config.e10.privateAddress}" = [
        "${hosts.gateway.config.e10.publicAddress}:${
          toString hosts.gateway.config.services.nebula.networks.e10.listen.port
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
