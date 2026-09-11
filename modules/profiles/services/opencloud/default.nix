{ config, pkgs, ... }:
let
  storagePath = "/data/files/services/opencloud";

  url = "https://cloud.e10.camp";
  issuer = "https://auth.e10.camp";

  clientId = "QAGTWBU5gQ5aemug~ORuMe.J~cZWuqCZbRSIw7il_Eo.nWKR3irBuTLde~IitPzQkwEIfGXI";

  cspFile = (pkgs.formats.yaml { }).generate "opencloud-csp.yaml" {
    directives = {
      "child-src" = [ "'self'" ];
      "connect-src" = [
        "'self'"
        "blob:"
        "${issuer}/"
        "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        "https://update.opencloud.eu/"
        "https://tile.openstreetmap.org/"
      ];
      "default-src" = [ "'none'" ];
      "font-src" = [ "'self'" ];
      "frame-ancestors" = [ "'self'" ];
      "frame-src" = [
        "'self'"
        "blob:"
        "https://embed.diagrams.net/"
        "${issuer}/"
      ];
      "img-src" = [
        "'self'"
        "data:"
        "blob:"
        "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
        "https://tile.openstreetmap.org/"
      ];
      "manifest-src" = [ "'self'" ];
      "media-src" = [ "'self'" ];
      "object-src" = [
        "'self'"
        "blob:"
      ];
      "script-src" = [
        "'self'"
        "'unsafe-inline'"
        "${issuer}/"
      ];
      "style-src" = [
        "'self'"
        "'unsafe-inline'"
        "blob:"
      ];
      "worker-src" = [
        "'self'"
        "blob:"
      ];
    };
  };
in
{
  sops = {
    secrets = {
      opencloud_admin_password = {
        sopsFile = ./secrets.json;
        owner = config.services.opencloud.user;
      };
    };

    templates."opencloud/environment_file" = {
      content = ''
        ADMIN_PASSWORD=${config.sops.placeholder.opencloud_admin_password}
      '';
      owner = config.services.opencloud.user;
    };
  };

  systemd.tmpfiles.settings."10-opencloud" = {
    ${storagePath} = {
      "d" = {
        inherit (config.services.opencloud) user group;
        mode = "0750";
      };
    };
  };

  services.opencloud = {
    enable = true;

    inherit url;

    address = "0.0.0.0";
    port = 9200;
    stateDir = storagePath;

    environmentFile = config.sops.templates."opencloud/environment_file".path;

    environment = {
      OC_INSECURE = "true";
      PROXY_TLS = "false";

      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = issuer;
      PROXY_OIDC_ISSUER = issuer;

      PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";

      PROXY_OIDC_REWRITE_WELLKNOWN = "true";

      PROXY_CSP_CONFIG_FILE_LOCATION = "${cspFile}";

      # Default is 9100, collides with prometheus-node-exporter
      WEB_HTTP_ADDR = "127.0.0.1:19100";

      WEB_OIDC_CLIENT_ID = clientId;
      WEB_OIDC_AUTHORITY = issuer;
      WEB_OIDC_METADATA_URL = "${issuer}/.well-known/openid-configuration";
      WEB_OIDC_RESPONSE_TYPE = "code";
      WEB_OIDC_SCOPE = "openid profile email groups offline_access";
      PROXY_OIDC_CLIENT_ID = clientId;

      WEBFINGER_WEB_OIDC_CLIENT_ID = clientId;
      WEBFINGER_WEB_OIDC_CLIENT_SCOPES = "openid profile email groups offline_access";
      WEBFINGER_DESKTOP_OIDC_CLIENT_SCOPES = "openid profile email groups offline_access";
      WEBFINGER_ANDROID_OIDC_CLIENT_SCOPES = "openid profile email groups offline_access";
      WEBFINGER_IOS_OIDC_CLIENT_SCOPES = "openid profile email groups offline_access";

      PROXY_AUTOPROVISION_ACCOUNTS = "true";
      PROXY_AUTOPROVISION_CLAIM_USERNAME = "preferred_username";
      PROXY_AUTOPROVISION_CLAIM_EMAIL = "email";
      PROXY_AUTOPROVISION_CLAIM_DISPLAYNAME = "name";
      PROXY_AUTOPROVISION_CLAIM_GROUPS = "groups";

      PROXY_USER_OIDC_CLAIM = "preferred_username";
      PROXY_USER_CS3_CLAIM = "username";
      GRAPH_USERNAME_MATCH = "none";

      GRAPH_ASSIGN_DEFAULT_USER_ROLE = "false";

      OC_LOG_LEVEL = "warn";
    };

    settings.proxy.role_assignment = {
      driver = "oidc";
      oidc_role_mapper = {
        role_claim = "groups";
        role_mapping = [
          {
            role_name = "admin";
            claim_value = "opencloud_admins";
          }
          {
            role_name = "user";
            claim_value = "opencloud_users";
          }
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.opencloud.port ];
}
