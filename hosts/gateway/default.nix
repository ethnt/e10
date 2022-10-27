{ config, lib, pkgs, suites, hosts, modulesPath, ... }: {
  imports = with suites;
    base ++ network ++ aws ++ web ++ gateway ++ observability;

  camp = {
    privateAddress = config.services.nebula.networks.camp.address;
    publicAddress = "3.136.251.131";
    domain = "gateway.camp.computer";
    deployable = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nebula_host_key = { };
      nebula_host_cert = { };
    };
  };

  services.nebula.networks.camp = {
    address = "10.10.0.1";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  services.nginx.virtualHosts = {
    "e10.land" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.matrix.config.camp.privateAddress}:8080";
      };
    };

    "blocky.camp.computer" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.matrix.config.camp.privateAddress}:${
            toString hosts.matrix.config.services.blocky.settings.httpPort
          }";
      };
    };
  };

  networking.hostName = "gateway";
}
