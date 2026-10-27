{ config, ... }: {
  services.crowdsec-firewall-bouncer = {
    enable = true;

    # The LAPI lives on `controller`, so the bouncer is registered there manually
    registerBouncer.enable = false;
    secrets.apiKeyPath = config.sops.secrets.crowdsec_firewall_bouncer_api_key.path;

    settings.api_url = "http://controller:8180";
  };
}
