_:
let
  disks = {
    scsi = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

    nvme0 = "/dev/disk/by-id/nvme-eui.0025384a51403eec";
    nvme1 = "/dev/disk/by-id/nvme-eui.0025384a51403ea5";
    nvme2 = "/dev/disk/by-id/nvme-eui.0025384a51403e68";
    nvme3 = "/dev/disk/by-id/nvme-eui.0025384a514037ac";

    hdd0 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5YRX1";
    hdd1 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5JMZQ";
    hdd2 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5LLGS";
    hdd3 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5HXLV";
    hdd4 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5NLRJ";
    hdd5 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5PF99";
    hdd6 = "/dev/disk/by-id/ata-ST20000NM007D-3DJ103_ZVT5MMBQ";
    hdd7 = "/dev/disk/by-id/ata-WDC_WD181KFGX-68CKWN0_PNG2ZUJP";
  };
in {
  disko.devices = {
    disk = let
      addToZfsPool = { device, pool }: {
        inherit device;

        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                inherit pool;
                type = "zfs";
              };
            };
          };
        };
      };
    in {
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

      hdd0 = addToZfsPool {
        device = disks.hdd0;
        pool = "files";
      };

      hdd1 = addToZfsPool {
        device = disks.hdd1;
        pool = "files";
      };

      hdd2 = addToZfsPool {
        device = disks.hdd2;
        pool = "blockbuster";
      };

      hdd3 = addToZfsPool {
        device = disks.hdd3;
        pool = "blockbuster";
      };

      hdd4 = addToZfsPool {
        device = disks.hdd4;
        pool = "blockbuster";
      };

      hdd5 = addToZfsPool {
        device = disks.hdd5;
        pool = "blockbuster";
      };

      hdd6 = addToZfsPool {
        device = disks.hdd6;
        pool = "blockbuster";
      };

      hdd7 = addToZfsPool {
        device = disks.hdd7;
        pool = "blockbuster";
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

      files = {
        type = "zpool";
        mode = "mirror";

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
          zpool add -f files log mirror ${disks.nvme0} ${disks.nvme1}
        '';

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/data/files";
            options = {
              canmount = "on";
              mountpoint = "legacy";
            };
          };
        };
      };

      blockbuster = {
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
          zpool add -f blockbuster log ${disks.nvme2}
          zpool add -f blockbuster cache ${disks.nvme3}
        '';

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/data/blockbuster";
            options = {
              canmount = "on";
              mountpoint = "legacy";
            };
          };

          "media" = {
            type = "zfs_fs";
            mountpoint = "/data/blockbuster/media";
            options = {
              canmount = "on";
              mountpoint = "legacy";
            };
          };

          "tmp" = {
            type = "zfs_fs";
            mountpoint = "/data/blockbuster/tmp";
            options = {
              canmount = "on";
              mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
}
