{ config, ... }: {
  services.tautulli.enable = true;

  networking.firewall.allowedTCPPorts = [ config.services.tautulli.port ];
}
