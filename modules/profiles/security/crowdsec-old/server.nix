{ config, ... }:
let
  cfg = config.services.crowdsec;
in
{
  imports = [ ./common.nix ];

  sops = {
    secrets = {
      crowdsec_console_enroll_key = {
        sopsFile = ./secrets.json;
        owner = cfg.user;
        inherit (cfg) group;
      };

      crowdsec_capi_login = {
        sopsFile = ./secrets.json;
        owner = cfg.user;
        inherit (cfg) group;
      };

      crowdsec_capi_password = {
        sopsFile = ./secrets.json;
        owner = cfg.user;
        inherit (cfg) group;
      };
    };

    templates = {
      crowdsec_capi_credentials = {
        content = ''
          url: https://api.crowdsec.net/
          login: ${config.sops.placeholder.crowdsec_capi_login}
          password: ${config.sops.placeholder.crowdsec_capi_password}
        '';
        owner = cfg.user;
        inherit (cfg) group;
      };
    };
  };

  services.crowdsec.settings = {
    config.api.server = {
      # 8080 is taken by UniFi on `controller`
      listen_uri = "0.0.0.0:8180";
      online_client.credentials_path = config.sops.templates.crowdsec_capi_credentials.path;
    };

    console = {
      enrollKeyFile = config.sops.secrets.crowdsec_console_enroll_key.path;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8180 ];
}
