{ config, ... }: {
  services.tautulli.enable = true;

  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port ];

  provides.tautulli = {
    name = "Tautulli";
    http = {
      inherit (config.services.tautulli) port;
      proxy = {
        enable = true;
        domain = "tautulli.e10.camp";
      };
    };
  };
}
