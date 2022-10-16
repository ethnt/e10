{ config, suites, ... }: {
  imports = with suites;
    base ++ network ++ aws ++ observability ++ web ++ monitor;

  camp = {
    privateAddress = config.services.nebula.networks.camp.address;
    publicAddress = "18.219.39.43";
    domain = "monitor.camp.computer";
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nebula_host_key = { };
      nebula_host_cert = { };
    };
  };

  services.nebula.networks.camp = {
    address = "10.10.0.2";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  networking.hostName = "monitor";
}
