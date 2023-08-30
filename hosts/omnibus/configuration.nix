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
      profiles.sharing.nfs-server
      profiles.networking.satan
      profiles.users.blockbuster
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  e10 = {
    name = "omnibus";
    privateAddress = "192.168.10.11";
    publicAddress = "192.168.10.207";
    domain = "omnibus.e10.camp";
  };

  networking.interfaces.ens18.ipv4.addresses = [{
    address = config.e10.privateAddress;
    prefixLength = 24;
  }];

  services.nfs.server.exports = let
    options = "rw,sync,no_subtree_check,insecure,crossmnt,all_squash,anonuid=${
        toString config.users.users.blockbuster.uid
      },anongid=${toString config.users.groups.blockbuster.gid}";
  in ''
    ${config.disko.devices.zpool.blockbuster.datasets.root.mountpoint} 192.168.0.0/16(${options}) 100.0.0.0/8(${options})
  '';

  system.stateVersion = "23.11";
}
