{ config, lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ homelab ++ web ++ [
      profiles.services.miniflux.default
      profiles.services.e10-land
      profiles.networking.printing
      profiles.emulation.aarch64-linux
      profiles.power.tripp-lite
      profiles.telemetry.prometheus-nut-exporter
      profiles.services.netbox.default
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  satan.address = "192.168.10.31";

  networking.interfaces.ens18.ipv4.addresses = [{
    inherit (config.satan) address;
    prefixLength = 24;
  }];

  e10.services.backup.jobs.system.paths = lib.mkAfter [ "/var/www" ];

  system.stateVersion = "23.11";
}
