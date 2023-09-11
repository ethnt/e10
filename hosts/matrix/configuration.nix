{ config, lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ homelab ++ web ++ [
      profiles.services.miniflux.default
      profiles.services.e10-land
      profiles.networking.printing
      profiles.emulation.aarch64-linux
      profiles.power.tripp-lite
      profiles.telemetry.prometheus-nut-exporter
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  e10 = {
    name = "matrix";
    privateAddress = "192.168.10.31";
    publicAddress = "192.168.10.31";
    domain = "matrix.e10.camp";
  };

  networking.interfaces.ens18.ipv4.addresses = [{
    address = config.e10.privateAddress;
    prefixLength = 24;
  }];

  e10.services.backup.jobs.system.paths = lib.mkAfter [ "/var/www" ];

  system.stateVersion = "23.11";
}
