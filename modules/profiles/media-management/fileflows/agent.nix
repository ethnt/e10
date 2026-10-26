{ hosts, pkgs, ... }: {
  services.fileflows.agent = {
    enable = true;
    extraPkgs = with pkgs; [ jellyfin-ffmpeg ];
    serverUrl = "http://${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.fileflows.server.port}";
    libraryDirs = [ "/mnt/blockbuster/media" ];
  };
}
