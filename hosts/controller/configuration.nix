{ profiles, suites, ... }: {
  imports = with suites;
    core ++ local ++ proxmox-vm ++ [
      profiles.networking.blocky.default
      profiles.networking.unifi
      profiles.power.eaton-5p550r
      profiles.services.attic-watch-store.default
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
      profiles.telemetry.prometheus-unpoller-exporter.satan
      profiles.networking.speedtest-tracker
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
