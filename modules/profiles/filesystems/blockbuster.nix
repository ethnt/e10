{ hosts, profiles, ... }: {
  imports = [ profiles.users.blockbuster ];

  fileSystems."/mnt/blockbuster" = {
    device = "${hosts.omnibus.config.satan.address}:${hosts.omnibus.config.disko.devices.zpool.blockbuster.datasets.root.mountpoint}";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "exec"
      "vers=4.2"
      "nconnect=8"
      "rsize=1048576"
      "wsize=1048576"
      "noatime"
    ];
  };
}
