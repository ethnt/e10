{ lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ nuc ++ [ profiles.hypervisors.proxmox-ve ]
    ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/nvme-CT4000P3SSD8_2322E6DDD8FE" ];

  deployment = {
    buildOnTarget = true;
    tags = [ "hypervisor" ];
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
