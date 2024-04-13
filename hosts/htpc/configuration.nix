{ config, lib, suites, profiles, hosts, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
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

  deployment = { tags = [ "vm" ]; };

  satan.address = "10.10.2.1";

  deployment.buildOnTarget = true;

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
          options.src = "10.10.2.1";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.2.1";
          prefixLength = 24;
        }];
      };
    };
  };

  fileSystems."/mnt/blockbuster" = {
    device =
      "10.10.1.1:${hosts.omnibus.config.disko.devices.zpool.blockbuster.datasets.root.mountpoint}";
    fsType = "nfs";
    options = [ "x-systemd.automount" "exec" ];
  };

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/plex/Plex Media Server/Cache" ];

  system.stateVersion = "23.11";
}
