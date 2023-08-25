{ inputs, config, lib, pkgs, suites, profiles, ... }: {
  imports = with suites;
    core ++ [
      profiles.virtualisation.qemu
      profiles.filesystems.hybrid-boot
      profiles.filesystems.zfs
      profiles.hardware.intel
      profiles.hardware.hidpi
      profiles.hardware.ssd
      profiles.telemetry.smartd
      profiles.telemetry.prometheus-smartctl-exporter
      profiles.telemetry.prometheus-zfs-exporter
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  e10 = {
    name = "omnibus";
    privateAddress = "100.71.83.137";
    publicAddress = "192.168.10.207";
    domain = "omnibus.e10.camp";
  };

  # Temporary for data transfer
  # https://unix.stackexchange.com/a/367216
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  system.stateVersion = "23.11";
}
