{ config, lib, pkgs, suites, modulesPath, ... }: {
  imports = with suites; base ++ network ++ aws ++ gateway ++ observability;

  camp = {
    privateAddress = config.services.nebula.networks.camp.address;
    publicAddress = "3.136.251.131";
    domain = "gateway.camp.computer";
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

  networking.hostName = "gateway";
}
