{ config, suites, profiles, ... }: {
  imports = with suites;
    core ++ homelab ++ proxmox-vm
    ++ [ profiles.remote-builder.builder profiles.remote-builder.substituter ]
    ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  satan.address = "192.168.10.22";

  networking.interfaces.ens18.ipv4.addresses = [{
    inherit (config.satan) address;
    prefixLength = 24;
  }];

  system.stateVersion = "23.11";
}
