{ lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.databases.postgresql.default
      profiles.networking.blocky.default
      profiles.networking.blocky.redis
      profiles.networking.blocky.postgresql
      profiles.networking.tailscale.exit-node
      profiles.networking.unifi
      profiles.power.apc
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
      profiles.networking.networkd
      profiles.networking.resolved
      profiles.telemetry.prometheus-unpoller-exporter
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

  satan.address = "192.168.1.2";

  deployment.targetHost = "192.168.1.2";
  deployment.buildOnTarget = true;

  services.resolved.extraConfig = ''
    [Resolve]
    DNS=127.0.0.52
  '';

  networking.firewall.extraCommands = ''
    iptables -t nat -A OUTPUT -d 127.0.0.52 -p udp -m udp --dport 53 -j REDIRECT --to-ports 52
    iptables -t nat -A OUTPUT -d 127.0.0.52 -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 52
  '';

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = "ens18";
    };
    nameservers = [ "192.168.1.1" ];

    vlans.vlan2 = {
      id = 2;
      interface = "ens18";
    };

    interfaces = {
      vlan2.ipv4.addresses = [{
        address = "10.2.2.1";
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
