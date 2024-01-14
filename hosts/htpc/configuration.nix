{ config, lib, suites, profiles, hosts, ... }: {
  imports = with suites;
    core ++ homelab ++ proxmox-vm ++ [
      profiles.hardware.nvidia
      profiles.sharing.nfs-client
      profiles.virtualisation.docker
      profiles.users.blockbuster
      profiles.media-management.bazarr
      profiles.media-management.overseerr
      profiles.media-management.plex
      profiles.media-management.prowlarr
      profiles.media-management.radarr
      profiles.media-management.sabnzbd
      profiles.media-management.sonarr
      profiles.media-management.tautulli
      profiles.media-management.xteve
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  e10 = {
    name = "htpc";
    privateAddress = "192.168.10.21";
    domain = "htpc.e10.camp";
  };

  networking.interfaces.enp6s18.ipv4.addresses = [{
    address = config.e10.privateAddress;
    prefixLength = 24;
  }];

  fileSystems."/mnt/blockbuster" = {
    device =
      "${hosts.omnibus.config.e10.privateAddress}:${hosts.omnibus.config.disko.devices.zpool.blockbuster.datasets.root.mountpoint}";
    fsType = "nfs";
    options = [ "x-systemd.automount" "exec" ];
  };

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/plex/Plex Media Server/Cache" ];

  system.stateVersion = "23.11";
}
