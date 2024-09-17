{ suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.services.attic-watch-store.default
      profiles.emulation.aarch64-linux
      profiles.remote-builder.builder
      profiles.remote-builder.substituter
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  satan.address = "10.10.2.102";

  deployment = {
    buildOnTarget = true;
    tags = [ "@vm" "@build-on-target" ];
  };

  nix.gc.automatic = false;

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];

    vlans.vlan10 = {
      id = 10;
      interface = "enp6s18";
    };

    interfaces = {
      vlan10.ipv4 = {
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.10.0.1";
          options.src = "10.10.2.102";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.2.102";
          prefixLength = 24;
        }];
      };
    };
  };

  system.stateVersion = "23.11";
}
