{ suites, profiles, ... }: {
  imports = with suites;
    core ++ homelab ++ proxmox-vm ++ [ profiles.remote-builder.builder ]
    ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  e10 = {
    name = "builder";
    privateAddress = "192.168.10.22";
    domain = "builder.e10.camp";
  };

  networking.interfaces.ens18.ipv4.addresses = [{
    address = "192.168.10.22";
    prefixLength = 24;
  }];

  system.stateVersion = "23.11";
}
