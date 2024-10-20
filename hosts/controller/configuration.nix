{ profiles, suites, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.services.attic-watch-store.default
      profiles.networking.tailscale.exit-node
      profiles.networking.blocky.default
      profiles.networking.blocky.redis
      profiles.networking.blocky.postgresql
      profiles.networking.unifi
      profiles.telemetry.prometheus-smokeping-exporter
      profiles.telemetry.prometheus-unpoller-exporter.satan
      profiles.power.apc-back-ups-xs-1500
      profiles.telemetry.prometheus-nut-exporter
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

  deployment = {
    buildOnTarget = false;
    tags = [ "@vm" "@build-on-target" ];
  };

  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = "ens18";
    };

    nameservers = [ "9.9.9.9" ];

    vlans.vlan2 = {
      id = 2;
      interface = "ens18";
    };

    interfaces = {
      vlan2.ipv4.addresses = [{
        address = "10.2.1.2";
        prefixLength = 24;
      }];

      ens18.ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };
  };

  system.stateVersion = "24.05";
}
