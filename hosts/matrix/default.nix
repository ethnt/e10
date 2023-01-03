{ config, pkgs, suites, profiles, ... }: {
  imports = with suites;
    base ++ network ++ proxmox ++ observability ++ web ++ (with profiles; [
      databases.redis.blocky
      networking.blocky.common
      networking.blocky.local
      networking.unifi
      power.apcupsd
      monitoring.prometheus-apcupsd-exporter
      applications.e10-land
      hardware.nuc
      networking.printing
      networking.avahi
      applications.miniflux
      databases.postgresql.common
      databases.postgresql.blocky
    ]);

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

  fileSystems."/mnt/omnibus" = {
    device = "192.168.1.201:/mnt/omnibus/matrix";
    fsType = "nfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.device-timeout=10"
    ];
  };

  services.nginx.virtualHosts = {
    "pve.e10.network" = {
      listen = [{
        addr = "0.0.0.0";
        port = 9010;
      }];

      locations."/" = {
        proxyPass = "http://192.168.1.200";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 9010 ];
}
