{ config, ... }: {
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;

    extraNfsdConfig = "upd=y";
  };

  networking.firewall = let
    ports = [
      204
      111
      20048
      config.services.nfs.server.statdPort
      config.services.nfs.server.lockdPort
      2049
    ];
  in {
    allowedUDPPorts = ports;
    allowedTCPPorts = ports;
  };
}
