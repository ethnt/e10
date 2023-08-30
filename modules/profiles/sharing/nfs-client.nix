{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [ nfs-utils ];

  boot.initrd = {
    supportedFilesystems = lib.mkAfter [ "nfs" ];
    kernelModules = lib.mkAfter [ "nfs" ];
  };
}
