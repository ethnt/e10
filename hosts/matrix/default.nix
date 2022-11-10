{ config, pkgs, suites, ... }: {
  imports = with suites;
    base ++ network ++ proxmox ++ observability ++ web ++ matrix;

  e10 = {
    privateAddress = config.services.nebula.networks.e10.address;
    publicAddress = "192.168.1.203";
    domain = "matrix.e10.network";
    deployable = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nebula_host_key = { };
      nebula_host_cert = { };
    };
  };

  services.nebula.networks.e10 = {
    address = "10.10.0.4";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  environment.systemPackages = with pkgs; [ dig ];

  networking.hostName = "matrix";
}
