{ suites, profiles, ... }: {
  imports =
    with suites;
    core
    ++ rpi4
    ++ [
      profiles.power.tripp-lite-smart1500lcd
      profiles.telemetry.prometheus-nut-exporter
    ];

  deployment.targetHost = "10.2.200.1";

  networking = {
    useDHCP = false;
    nameservers = [ "10.2.0.1" ];
  };

  systemd.network = {
    netdevs = {
      "10-vlan2" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan2";
        };
        vlanConfig.Id = 2;
      };
    };

    networks = {
      "10-end0" = {
        matchConfig.Name = "end0";
        networkConfig = {
          VLAN = [ "vlan2" ];
          DHCP = "no";
          LinkLocalAddressing = "no";
        };
        linkConfig.RequiredForOnline = "no";
      };
      "20-vlan2" = {
        matchConfig.Name = "vlan2";
        address = [ "10.2.200.1/24" ];
        routes = [
          {
            Destination = "0.0.0.0/0";
            Gateway = "10.2.0.1";
            GatewayOnLink = true;
          }
        ];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  system.stateVersion = "26.05";
}
