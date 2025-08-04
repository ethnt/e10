{ config, pkgs, suites, profiles, ... }: {
  imports = with suites;
    core ++ proxmox-vm ++ [
      profiles.communications.postfix.default
      profiles.databases.postgresql.default
      profiles.services.attic-watch-store.default
      profiles.services.atticd.default
      profiles.services.garage.default
      profiles.sharing.nfs-server
      profiles.sharing.samba
      profiles.telemetry.prometheus-smartctl-exporter
      profiles.telemetry.prometheus-zfs-exporter
      profiles.telemetry.smartd
      profiles.users.blockbuster
      profiles.users.ethan
      profiles.users.files
      profiles.users.nicole
      profiles.users.proxmox
    ] ++ [ ./hardware-configuration.nix ./disk-config.nix ];

  boot.loader.grub.devices =
    [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" ];

  deployment = {
    buildOnTarget = true;
    tags = [ "@vm" "@build-on-target" ];
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

  services.samba.settings = {
    proxmox = {
      path = "/data/files/proxmox";
      browseable = "no";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.proxmox.name;
    };

    personal = {
      path = "/data/files/personal";
      browseable = "no";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.ethan.name;
      "valid users" = config.users.users.ethan.name;
    };

    backup = {
      path = "/data/files/backup";
      browseable = "no";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.ethan.name;
    };

    nicole = {
      path = "/data/files/nicole";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = config.users.users.nicole.name;
      "force group" = config.users.users.nicole.group;
    };
  };

  environment.systemPackages = with pkgs; [ yt-dlp ];

  # programs.fish.shellAliases.iotop = ''
  #   bash -c "sudo sysctl kernel.task_delayacct=1 && sudo ${pkgs.iotop}/bin/iotop ; sudo sysctl kernel.task_delayacct=0"
  # '';

  services.borgmatic.configurations.files = {
    source_directories = [ "/data/files" ];
    exclude_patterns = [ "/data/files/backup" ];
    repositories = [{
      label = "rsync.net";
      path = "ssh://de2228@de2228.rsync.net/./omnibus-files";
    }];
    keep_daily = 1;
    keep_weekly = 2;
    keep_monthly = 2;
  };

  system.stateVersion = "24.05";
}
