{
  disko.devices = {
    disk = {
      main = {
        type = "disk";

        # Pinned by path, not `/dev/sda`: the data volume is attached before
        # disko runs, and sd* ordering between the two isn't guaranteed. By-id
        # would be unambiguous too, but its serial is per-server and unknowable
        # before the server exists.
        #
        # This path was read off gateway (cpx11, no volume attached); it is
        # assumed, not verified, to be identical on cpx31 with a volume. If it
        # differs, disko aborts with "device not found" rather than
        # repartitioning the wrong disk, which is the point of pinning it.
        device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:0";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
