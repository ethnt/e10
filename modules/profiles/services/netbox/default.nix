{ config, pkgs, ... }: {
  sops.secrets = {
    netbox_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };

    netbox_oauth_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    secretKeyFile = config.sops.secrets.netbox_secret_key.path;
    listenAddress = "0.0.0.0";
    settings = {
      CSRF_TRUSTED_ORIGINS = [
        "https://netbox.e10.camp"
        "http://${config.networking.hostName}:${
          toString config.services.netbox.port
        }"
        "http://${config.networking.hostName}:8002"
      ];
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_BACKEND =
        "social_core.backends.open_id_connect.OpenIdConnectAuth";
      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://auth.e10.camp";
      SOCIAL_AUTH_OIDC_KEY =
        "gY0aO8QGJT.~UbRntqa72YTm54DSUHr3HeBu4zMBlWwMwlJwLtbhXflUCAczeC-snr9I_5tZ";
    };
    extraConfig = ''
      import os

      with open("${config.sops.secrets.netbox_oauth_secret_key.path}", "r") as file:
        SOCIAL_AUTH_OIDC_SECRET = file.readline()

      SOCIAL_AUTH_BACKEND_ATTRS = {
        'oidc': ("Login with Authelia", "login")
      }
    '';
  };

  services.caddy.virtualHosts."http://netbox.e10.camp:8002" = {
    extraConfig = ''
      encode gzip zstd

      root * ${config.services.netbox.dataDir}

      @proxied {
        not path /static/*
      }

      reverse_proxy @proxied http://localhost:${
        toString config.services.netbox.port
      }

      file_server
    '';
  };

  # Needed so Caddy can read Netbox's static files
  users.groups.netbox.members = [ config.services.caddy.user ];

  services.postgresqlBackup.databases = [ "netbox" ];

  networking.firewall.allowedTCPPorts = [ config.services.netbox.port 8002 ];
}
