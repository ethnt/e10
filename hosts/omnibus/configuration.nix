{ config, pkgs, suites, profiles, ... }: {
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
      profiles.databases.postgresql.default
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  satan.address = "192.168.10.11";

  networking.interfaces.ens18.ipv4.addresses = [{
    inherit (config.satan) address;
    prefixLength = 24;
  }];

  services.nfs.server.exports = let
    options = "rw,sync,no_subtree_check,insecure,crossmnt,all_squash,anonuid=${
        toString config.users.users.blockbuster.uid
      },anongid=${toString config.users.groups.blockbuster.gid}";
  in ''
    ${config.disko.devices.zpool.blockbuster.datasets.root.mountpoint} 192.168.0.0/16(${options}) 100.0.0.0/8(${options})
  '';

  services.samba.shares = {
    proxmox = {
      path = "/data/files/proxmox";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.proxmox.name;
    };

    personal = {
      path = "/data/files/personal";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.ethan.name;
    };
  };

  e10.services.backup.jobs.files = {
    repoName = "${config.networking.hostName}-files";
    paths = [ "/data/files" ];
  };

  programs.fish.shellAliases.iotop = ''
    bash -c "sudo sysctl kernel.task_delayacct=1 && sudo ${pkgs.iotop}/bin/iotop ; sudo sysctl kernel.task_delayacct=0"
  '';

  system.stateVersion = "23.11";
}
