{ config, pkgs, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.telemetry.smartd
      profiles.telemetry.prometheus-smartctl-exporter
      profiles.telemetry.prometheus-zfs-exporter
      profiles.sharing.nfs-server
      profiles.users.blockbuster
      profiles.users.files
      profiles.sharing.samba
      profiles.users.ethan
      profiles.users.proxmox
      profiles.databases.postgresql.default
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  deployment = {
    buildOnTarget = true;
    tags = [ "vm" ];
  };

  satan.address = "10.10.1.101";

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];

    vlans.vlan10 = {
      id = 10;
      interface = "ens18";
    };

    interfaces = {
      vlan10.ipv4 = {
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.10.0.1";
          options.src = "10.10.1.101";
          options.onlink = "";
        }];
        addresses = [{
          address = "10.10.1.101";
          prefixLength = 24;
        }];
      };
    };
  };

  services.nfs.server.exports = let
    blockbusterOptions =
      "rw,sync,no_subtree_check,insecure,crossmnt,all_squash,anonuid=${
        toString config.users.users.blockbuster.uid
      },anongid=${toString config.users.groups.blockbuster.gid}";
    filesOptions =
      "rw,sync,no_subtree_check,insecure,crossmnt,all_squash,anonuid=${
        toString config.users.users.files.uid
      },anongid=${toString config.users.groups.files.gid}";
  in ''
    ${config.disko.devices.zpool.blockbuster.datasets.root.mountpoint} 192.168.0.0/16(${blockbusterOptions}) 100.0.0.0/8(${blockbusterOptions}) 10.10.0.0/16(${blockbusterOptions})
    ${config.disko.devices.zpool.files.datasets.root.mountpoint} 192.168.0.0/16(${filesOptions}) 100.0.0.0/8(${filesOptions}) 10.10.0.0/16(${filesOptions})
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

  environment.systemPackages = with pkgs; [ yt-dlp ];

  e10.services.backup.jobs.files = {
    repoName = "${config.networking.hostName}-files";
    paths = [ "/data/files" ];
    pruneKeep = {
      monthly = 1;
      weekly = 0;
      daily = 0;
    };
  };

  programs.fish.shellAliases.iotop = ''
    bash -c "sudo sysctl kernel.task_delayacct=1 && sudo ${pkgs.iotop}/bin/iotop ; sudo sysctl kernel.task_delayacct=0"
  '';

  system.stateVersion = "23.11";
}
