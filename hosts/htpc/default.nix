{ config, pkgs, suites, ... }: {
  imports = with suites; base ++ network ++ proxmox ++ observability ++ htpc;

  e10 = {
    privateAddress = config.services.nebula.networks.e10.address;
    publicAddress = "192.168.1.203";
    domain = "htpc.e10.network";
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
    address = "10.10.0.3";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  networking.hostName = "htpc";

  fileSystems."/mnt/omnibus" = {
    device = "192.168.1.201:/mnt/omnibus/htpc";
    fsType = "nfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.device-timeout=10"
    ];
  };
}
