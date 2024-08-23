{ config, pkgs, ... }: {
  services.fileflows = {
    enable = true;
    enableNvidia = true;
    openFirewall = true;
    extraVolumes = [
      "/mnt/blockbuster/tmp/fileflows:/temp"
      "/mnt/blockbuster/media:/mnt/blockbuster/media"
    ];
  };
}
