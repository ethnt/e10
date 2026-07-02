{ lib, suites, profiles, hosts, ... }: {
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
    preseed = {
      config = {
        core.https_address = ":8443";
        oidc = {
          issuer = "https://auth.e10.camp";
          client.id =
            "NE-kA1k.XTEv8Qe6oywlhfJHJVmLHg0474m3zD2nMjTm.ddl9rnK.Toq1WwetMP-BjYq4K0X";
          audience = "https://incus.dill.e10.camp";
        };
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
        "limits.cpu" = 2;
        "limits.memory" = "1GB";
      };
    }];
  };

  networking = {
    useDHCP = false;

    nameservers = [ "10.10.0.1" ];

    vlans.vlan10 = {
      id = 10;
      interface = "enp86s0";
    };

    bridges.vmbr0.interfaces = [ "enp86s0" ];

    interfaces = {
      vmbr0.useDHCP = lib.mkDefault true;

      vlan10.ipv4 = {
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.10.0.1";
          options.src = "10.10.4.0";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.4.0";
          prefixLength = 24;
        }];
      };
    };
  };

  system.stateVersion = "24.11";
}
