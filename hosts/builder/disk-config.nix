_:
let disks = { scsi = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"; };
in {
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = disks.scsi;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };

            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";

        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions = {
          acltype = "posixacl";
          compression = "lz4";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          mountpoint = "none";
        };

        postCreateHook = ''
          zfs snapshot zroot/root@empty
          zfs mount
        '';

        datasets = {
          "root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };

          "nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };

          "var" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var";
          };

          "persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };

          "home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
