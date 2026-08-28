{ pkgs, ... }: {
  services.fileflows.server = {
    enable = true;
    extraPkgs = with pkgs; [ jellyfin-ffmpeg ];
    libraryDirs = [ "/mnt/blockbuster/media" ];
    openFirewall = true;
  };
}
