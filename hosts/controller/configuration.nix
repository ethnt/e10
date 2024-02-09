{ suites, profiles, ... }: {
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

  e10 = {
    name = "controller";
    privateAddress = "10.0.2.11";
    domain = "controller";
  };

  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];

    vlans.vlan002 = {
      id = 2;
      interface = "ens18";
    };

    interfaces = {
      vlan002.ipv4.addresses = [{
        address = "10.0.2.11";
        prefixLength = 24;
      }];

      ens18.ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };
  };

  system.stateVersion = "23.11";
}
