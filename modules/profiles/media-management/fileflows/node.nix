{ hosts, ... }: {
  services.fileflows.node = {
    enable = true;
    serverUrl = "http://${hosts.htpc.config.networking.hostName}:${
        toString hosts.htpc.config.services.fileflows.server.port
      }";
    libraryDirs = [ "/mnt/blockbuster/media" ];
  };
}
