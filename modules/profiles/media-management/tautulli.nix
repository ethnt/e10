{ config, ... }: {
  services.tautulli.enable = true;

  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port ];

  provides.tautulli = {
    name = "Tautulli";
    http = {
      enable = true;
      inherit (config.services.tautulli) port;
      domain = "tautulli.e10.camp";
    };
  };
}
