{
  imports = [ ./common.nix ];

  # Alerts are sent to the LAPI on `controller`
  services.crowdsec.settings.config.api.server.enable = false;
}
