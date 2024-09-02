{ hosts, ... }: {
  services.fileflows-node = {
    enable = true;
    serverUrl = "http://${hosts.htpc.config.networking.hostName}:${
        toString hosts.htpc.config.services.fileflows-server.port
      }";
    extraVolumes = [
      "/mnt/blockbuster/tmp/fileflows:/temp"
      "/mnt/blockbuster/media:/mnt/blockbuster/media"
    ];
  };
}
