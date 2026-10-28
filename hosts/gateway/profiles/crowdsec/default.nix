{ config, ... }: {
  sops = {
    secrets = {
      crowdsec_lapi_password = {
        sopsFile = ./secrets.json;
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };

      crowdsec_firewall_bouncer_api_key = {
        sopsFile = ./secrets.json;
        mode = "0777";
      };

      crowdsec_caddy_bouncer_api_key = {
        sopsFile = ./secrets.json;
        mode = "0777";
      };
    };

    templates = {
      crowdsec_lapi_credentials = {
        content = ''
          url: http://monitor:8010
          login: ${config.networking.hostName}
          password: ${config.sops.placeholder.crowdsec_lapi_password}
        '';
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };

      crowdsec_caddy_bouncer_environment_file = {
        content = ''
          CROWDSEC_API_KEY=${config.sops.placeholder.crowdsec_caddy_bouncer_api_key}
        '';
        owner = "caddy";
      };
    };
  };

  services.crowdsec-firewall-bouncer = {
    secrets.apiKeyPath = config.sops.secrets.crowdsec_firewall_bouncer_api_key.path;
    settings = {
      api_url = "http://monitor:8010";
    };
  };

  services.caddy.environmentFile = config.sops.templates.crowdsec_caddy_bouncer_environment_file.path;
}
