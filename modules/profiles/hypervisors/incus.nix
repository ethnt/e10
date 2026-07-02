{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.incus-apply ];

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
    preseed = {
      networks = [ ];
      profiles = [{
        devices = {
          eth0 = {
            name = "eth0";
            type = "nic";
            nictype = "bridged";
            parent = "vmbr0";
          };
          root = {
            path = "/";
            pool = "default";
            size = "36GiB";
            type = "disk";
          };
        };
        name = "default";
      }];
      storage_pools = [{
        config = { source = "/var/lib/incus/storage-pools/default"; };
        driver = "dir";
        name = "default";
      }];
    };
  };

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "vmbr0" ];
}
