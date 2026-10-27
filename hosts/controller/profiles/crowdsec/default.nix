{ config, ... }: {
  sops = {
    secrets = {
      crowdsec_lapi_password = {
        sopsFile = ./secrets.json;
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };
    };

    templates = {
      crowdsec_lapi_credentials = {
        content = ''
          url: http://127.0.0.1:8180
          login: ${config.networking.hostName}
          password: ${config.sops.placeholder.crowdsec_lapi_password}
        '';
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };
    };
  };
}
