{ config, lib, profiles, ... }: {
  imports = [
    profiles.databases.postgresql.authelia
    profiles.databases.redis.authelia
  ];

  sops.secrets = {
    authelia_jwt_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    authelia_storage_encryption_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    authelia_session_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    authelia_oidc_hmac_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    authelia_issuer_private_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    aws_ses_smtp_username = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    aws_ses_smtp_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };

    authelia_ldap_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "authelia-gateway";
    };
  };

  services.authelia.instances.gateway = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
      storageEncryptionKeyFile =
        config.sops.secrets.authelia_storage_encryption_key.path;
      sessionSecretFile = config.sops.secrets.authelia_session_secret.path;
      oidcHmacSecretFile = config.sops.secrets.authelia_oidc_hmac_secret.path;
      oidcIssuerPrivateKeyFile =
        config.sops.secrets.authelia_issuer_private_key.path;
    };
    settings = {
      log.level = "debug";

      server = {
        address = "tcp://127.0.0.1:9091";
        endpoints.authz.forward-auth.implementation = "ForwardAuth";
      };

      authentication_backend.ldap = {
        address = "ldap://localhost:${
            toString config.services.lldap.settings.ldap_port
          }";
        base_dn = "dc=e10,dc=camp";
        users_filter = "(&({username_attribute}={input})(objectClass=person))";
        groups_filter = "(member={dn})";
        user = "uid=authelia,ou=people,dc=e10,dc=camp";
      };

      default_2fa_method = "webauthn";

      webauthn = {
        disable = false;
        display_name = "Two-Factor Authentication (2FA)";
        attestation_conveyance_preference = "indirect";
        user_verification = "preferred";
        timeout = "30s";
      };

      identity_providers.oidc.clients = [{
        client_id = "opengist";
        client_name = "Opengist";
        client_secret =
          "$pbkdf2-sha512$310000$zLrxDpiootQD8uDfes59Sg$eA7kxuydW7RPbDFBl3Wr5VT1GbzB3etfVjjPMM16zvlOIxJBBHAU/DBJY5oOyan8VRY4mu678FLVPJsaCDBm5Q";
        public = false;
        authorization_policy = "two_factor";
        redirect_uris =
          [ "https://gist.e10.camp/oauth/openid-connect/callback" ];
        scopes = [ "openid" "profile" "email" ];
        response_types = [ "code" ];
        grant_types = [ "authorization_code" ];
        response_modes = [ "form_post" "query" "fragment" ];
      }];

      access_control = {
        default_policy = "bypass";

        networks = [{
          name = "internal";
          networks =
            [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/18" "100.0.0.0/8" ];
        }];

        rules = lib.mkAfter [
          {
            domain = "fileflows.e10.camp";
            policy = "two_factor";
          }
          {
            domain = "fileflows.e10.camp";
            policy = "bypass";
            methods = [ "HEAD" ];
          }
          {
            domain = "fileflows.e10.camp";
            policy = "bypass";
            resources = [ "^/manifest.json" "^/api([/?].*)?$" ];
          }
          {
            domain = "*.e10.camp";
            policy = "bypass";
            methods = [ "HEAD" ];
          }
          {
            domain = "glance.e10.camp";
            policy = "two_factor";
          }
        ];
      };

      storage.postgres = {
        address = "unix:///run/postgresql";
        database = "authelia-gateway";
        username = "authelia-gateway";
        # Doesn't actually use this
        password = "authelia-gateway";
      };

      session = {
        redis = {
          host = "0.0.0.0";
          port = toString config.services.redis.servers.authelia-gateway.port;
        };
        cookies = [{
          domain = "e10.camp";
          authelia_url = "https://auth.e10.camp";
          inactivity = "1M";
          expiration = "3M";
          remember_me = "1y";
        }];
      };

      notifier = {
        # FIXME
        # disable_startup_check = true;
        # smtp = {
        #   address = "smtp://email-smtp.us-east-2.amazonaws.com:465";
        #   username = "AKIASLA22YHPQNBNENNK";
        #   sender = "auth@e10.camp";
        #   startup_check_address = "ethan@turkeltaub.me";
        # };
        filesystem.filename = "/var/lib/authelia-gateway/notifications.log";
      };

      telemetry = {
        metrics = {
          enabled = true;
          address = "tcp://0.0.0.0:9959";
        };
      };
    };

    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
        config.sops.secrets.authelia_ldap_password.path;
      # AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE =
      #   config.sops.secrets.aws_ses_smtp_password.path;
    };
  };

  systemd.services.authelia = let
    deps =
      [ "postgresql.service" "redis-authelia-gateway.service" "lldap.service" ];
  in {
    requires = deps;
    after = deps;
  };

  networking.firewall.allowedTCPPorts = [ 9959 ];
}
