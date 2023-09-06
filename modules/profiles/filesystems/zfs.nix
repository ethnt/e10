{ config, lib, ... }: {
  networking.hostId =
    lib.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);

  boot.zfs.devNodes = "/dev/disk/by-id";

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
