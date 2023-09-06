{ config, suites, profiles, ... }: {
  imports = with suites;
    core ++ homelab ++ proxmox-vm ++ [
      profiles.telemetry.smartd
      profiles.telemetry.prometheus-smartctl-exporter
      profiles.telemetry.prometheus-zfs-exporter
      profiles.sharing.nfs-server
      profiles.users.blockbuster
      profiles.sharing.samba
      profiles.users.ethan
      profiles.users.proxmox
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

  services.samba.shares.proxmox = {
    path = "/data/files/proxmox";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = config.users.users.proxmox.name;
  };

  services.samba.shares.personal = {
    path = "/data/files/personal";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = config.users.users.ethan.name;
  };

  e10.services.backup.jobs.files = {
    repoName = "${config.networking.hostName}-files";
    paths = [ "/data/files" ];
  };

  system.stateVersion = "23.11";
}
