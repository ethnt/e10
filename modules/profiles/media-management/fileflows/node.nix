{ hosts, pkgs, ... }: {
  services.fileflows.node = {
    enable = true;
    extraPkgs = with pkgs; [ ffmpeg-full ];
    serverUrl = "http://${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.fileflows.server.port}";
    libraryDirs = [ "/mnt/blockbuster/media" ];
  };
}
