{ hosts, profiles, ... }: {
  imports = [ profiles.users.blockbuster ];

  fileSystems."/mnt/blockbuster" = {
    device =
      "${hosts.omnibus.config.satan.address}:${hosts.omnibus.config.disko.devices.zpool.blockbuster.datasets.root.mountpoint}";
    fsType = "nfs";
    options = [ "x-systemd.automount" "exec" ];
  };
}
