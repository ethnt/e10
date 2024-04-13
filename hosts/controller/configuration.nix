{ flake, lib, config, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.databases.postgresql.blocky
      profiles.databases.postgresql.default
      profiles.databases.redis.blocky
      profiles.networking.blocky
      profiles.networking.tailscale.exit-node
      profiles.networking.unifi
      profiles.power.apc
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
      profiles.telemetry.prometheus-unpoller-exporter
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

  satan.address = "192.168.1.2";

  deployment.targetHost = "192.168.1.2";
  deployment.buildOnTarget = true;

  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];

    vlans.vlan2 = {
      id = 2;
      interface = "ens18";
    };

    interfaces = {
      vlan2.ipv4.addresses = [{
        address = "10.2.1.1";
        prefixLength = 24;
      }];

      ens18.ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };
  };

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/postgresql" "/var/lib/unifi/data/db" ];

  system.stateVersion = "23.11";
}
