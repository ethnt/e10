{ profiles, suites, lib, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.networking.blocky.default
      profiles.networking.blocky.redis
      profiles.networking.blocky.postgresql
      profiles.networking.tailscale.exit-node
      profiles.networking.networkd
      profiles.networking.resolved
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

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
        address = "10.2.1.2";
        prefixLength = 24;
      }];

      ens18.ipv4.addresses = [{
        address = "192.168.1.3";
        prefixLength = 24;
      }];
    };
  };

  system.stateVersion = "23.11";
}
