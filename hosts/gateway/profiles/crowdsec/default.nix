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
      };

      crowdsec_caddy_bouncer_api_key = {
        sopsFile = ./secrets.json;
      };
    };

    templates = {
      crowdsec_lapi_credentials = {
        content = ''
          url: http://controller:8180
          login: ${config.networking.hostName}
          password: ${config.sops.placeholder.crowdsec_lapi_password}
        '';
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };
    };
  };
}
