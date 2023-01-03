{
  services.tdarr.node = {
    enable = true;
    serverIP = "10.10.0.3";
    serverPort = 8266;
    extraVolumes = [ "/mnt/omnibus:/mnt/omnibus" ];
  };
}
