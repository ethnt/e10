{ config, lib, ... }: {
  networking.hostId =
    lib.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);

  boot = {
    zfs.devNodes = lib.mkForce "/dev/disk/by-id";

    initrd.supportedFilesystems = [ "zfs" ];
    supportedFilesystems = [ "zfs" ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
}
