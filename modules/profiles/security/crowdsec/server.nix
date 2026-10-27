{ config, ... }: {
  imports = [ ./common.nix ];

  sops = {
    secrets = {
      crowdsec_console_enroll_key = {
        sopsFile = ./secrets.json;
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
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
    };

    templates = {
      crowdsec_capi_credentials = {
        content = ''
          url: https://api.crowdsec.net/
          login: ${config.sops.placeholder.crowdsec_capi_login}
          password: ${config.sops.placeholder.crowdsec_capi_password}
        '';
        owner = config.services.crowdsec.user;
        inherit (config.services.crowdsec) group;
      };
    };
  };

  services.crowdsec.settings = {
    config.api.server = {
      listen_uri = "0.0.0.0:8180";
      online_client.credentials_path = config.sops.templates.crowdsec_capi_credentials.path;
    };

    console = {
      enrollKeyFile = config.sops.secrets.crowdsec_console_enroll_key.path;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8180 ];
}
