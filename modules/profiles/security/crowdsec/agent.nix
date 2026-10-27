{
  imports = [ ./common.nix ];

  services.crowdsec.settings.config.api.server.enable = false;
}
