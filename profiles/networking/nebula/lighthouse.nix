{ config, lib, ... }: {
  sops.secrets = { nebula_ca_cert = { sopsFile = ./secrets.yaml; }; };

  services.nebula.networks.camp = {
    isLighthouse = lib.mkOverride 10 true;
    lighthouses = lib.mkOverride 10 [ ];
    ca = config.sops.secrets.nebula_ca_cert.path;
    settings = {
      lighthouse = {
        serve_dns = true;
        dns = {
          host = "0.0.0.0";
          port = 53;
        };
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
}
