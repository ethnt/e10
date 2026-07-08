{ suites, profiles, hosts, ... }: {
  imports = with suites;
    core ++ nuc
    ++ [ profiles.hypervisors.incus profiles.hardware.intel-graphics ]
    ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/nvme-CT4000P3SSD8_2322E6DDD8FE" ];

  deployment = {
    deployable = true;
    buildOnTarget = true;
    tags = [ "hypervisor" ];
  };

  virtualisation.incus = {
    config = {
      core.https_address = ":8443";
      oidc = {
        issuer = "https://auth.e10.camp";
        client.id =
          "NE-kA1k.XTEv8Qe6oywlhfJHJVmLHg0474m3zD2nMjTm.ddl9rnK.Toq1WwetMP-BjYq4K0X";
        audience = "https://incus.dill.e10.camp";
      };
    };
    instances = [{
      name = "fennel";
      image = hosts.fennel.config.system.build.qemuImage;
      metadata = hosts.fennel.config.system.build.metadata;
      vm = true;
      profiles = [ "default" ];
      kind = "instance";
      config = {
        "limits.cpu" = 16;
        "limits.memory" = "8GiB";
      };
      devices = {
        eth0 = {
          type = "nic";
          nictype = "bridged";
          parent = "vmbr10";
        };
      };
    }];
  };

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];
  };

  systemd.network = {
    netdevs = {
      "10-vlan10" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan10";
        };
        vlanConfig.Id = 10;
      };
      "20-vmbr10" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "vmbr10";
        };
      };
    };
    networks = {
      "10-enp86s0" = {
        matchConfig.Name = "enp86s0";
        networkConfig = {
          VLAN = [ "vlan10" ];
          DHCP = "no";
          LinkLocalAddressing = "no";
        };
      };
      "20-vlan10" = {
        matchConfig.Name = "vlan10";
        networkConfig = {
          Bridge = "vmbr10";
          LinkLocalAddressing = "no";
        };
        linkConfig.RequiredForOnline = "no";
      };
      "30-vmbr10" = {
        matchConfig.Name = "vmbr10";
        address = [ "10.10.4.0/24" ];
        routes = [{
          routeConfig = {
            Destination = "0.0.0.0/0";
            Gateway = "10.10.0.1";
            GatewayOnLink = true;
          };
        }];
        networkConfig.LinkLocalAddressing = "no";
        linkConfig.RequiredForOnline = "no";
      };
    };
  };

  system.stateVersion = "24.11";
}
