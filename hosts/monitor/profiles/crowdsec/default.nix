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

      crowdsec_capi_login = {
        sopsFile = ./secrets.json;
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };

      crowdsec_capi_password = {
        sopsFile = ./secrets.json;
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };

      crowdsec_console_enroll_key = {
        sopsFile = ./secrets.json;
        mode = "0777";
      };
    };

    templates = {
      crowdsec_lapi_credentials = {
        content = ''
          url: http://localhost:8010
          login: ${config.networking.hostName}
          password: ${config.sops.placeholder.crowdsec_lapi_password}
        '';
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };

      crowdsec_capi_credentials = {
        content = ''
          url: https://api.crowdsec.net/
          login: ${config.sops.placeholder.crowdsec_capi_login}
          password: ${config.sops.placeholder.crowdsec_capi_password}
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

  services.crowdsec.settings = {
    config.api.server = {
      online_client.credentials_path = config.sops.templates.crowdsec_capi_credentials.path;
    };
    console = {
      enrollKeyFile = config.sops.secrets.crowdsec_console_enroll_key.path;
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
