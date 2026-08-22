# NOTE: Plugin migrations need to be run manually. This can be done on device:
#   $ netbox-manage migrate
{ config, pkgs, ... }:
let
  port = 8001;
in
{
  sops.secrets = {
    netbox_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };

    netbox_oauth_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };

    netbox_api_token_peppers = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    bind = "[::1]:${toString port}";
    plugins =
      _ps: with pkgs.netboxPlugins; [
        netbox-attachments
        netbox-interface-synchronization
        netbox-inventory
      ];
    secretKeyFile = config.sops.secrets.netbox_secret_key.path;
    apiTokenPeppersFile = config.sops.secrets.netbox_api_token_peppers.path;
    # listenAddress = "0.0.0.0";
    settings = {
      CSRF_TRUSTED_ORIGINS = [
        "https://netbox.e10.camp"
        "http://${config.networking.hostName}:${toString port}"
        "http://${config.networking.hostName}:8002"
      ];
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://auth.e10.camp";
      SOCIAL_AUTH_OIDC_KEY = "gY0aO8QGJT.~UbRntqa72YTm54DSUHr3HeBu4zMBlWwMwlJwLtbhXflUCAczeC-snr9I_5tZ";
      PLUGINS = [
        "netbox_attachments"
        "netbox_interface_synchronization"
        "netbox_inventory"
      ];
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

      reverse_proxy @proxied http://localhost:${toString port}

      file_server
    '';
  };

  # Needed so Caddy can read Netbox's static files
  users.groups.netbox.members = [ config.services.caddy.user ];

  services.postgresqlBackup.databases = [ "netbox" ];

  networking.firewall.allowedTCPPorts = [
    port
    8002
  ];
}
