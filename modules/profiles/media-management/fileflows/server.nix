{ pkgs, ... }: {
  services.fileflows.server = {
    enable = true;
    extraPkgs = with pkgs; [ ffmpeg-full ];
    libraryDirs = [ "/mnt/blockbuster/media" ];
    openFirewall = true;
  };
}
