{ config, suites, ... }: {
  imports = with suites; base ++ network ++ proxmox ++ observability ++ matrix;

  camp = {
    privateAddress = config.services.nebula.networks.camp.address;
    publicAddress = "192.168.1.212";
    domain = "matrix.camp.computer";
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
    address = "10.10.0.4";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  networking.hostName = "matrix";
}
