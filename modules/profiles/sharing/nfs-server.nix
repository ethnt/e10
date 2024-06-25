{ config, ... }: {
  services.nfs = {
    settings.nfsd.upd = "y";

    server = {
      enable = true;
      statdPort = 4000;
      lockdPort = 4001;
    };
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
