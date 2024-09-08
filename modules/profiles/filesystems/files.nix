{ hosts, profiles, ... }: {
  imports = [ profiles.users.files ];

  fileSystems."/mnt/files" = {
    device =
      "${hosts.omnibus.config.satan.address}:${hosts.omnibus.config.disko.devices.zpool.files.datasets.root.mountpoint}";
    fsType = "nfs";
    options = [ "x-systemd.automount" "exec" ];
  };
}
