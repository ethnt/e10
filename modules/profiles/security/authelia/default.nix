{ config, lib, ... }: {
  # imports = [
  #   profiles.databases.postgresql.authelia
  #   profiles.databases.redis.authelia
  # ];

  imports = [ ./postgresql.nix ./redis.nix ];

  sops.secrets = let
    owner =
      config.services.authelia.instances.${config.networking.hostName}.user;
  in {
    authelia_jwt_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    authelia_storage_encryption_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    authelia_session_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    authelia_oidc_hmac_secret = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    authelia_issuer_private_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    aws_ses_smtp_username = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    aws_ses_smtp_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };

    authelia_ldap_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      inherit owner;
    };
  };

  services.authelia.instances.${config.networking.hostName} = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
      storageEncryptionKeyFile =
        config.sops.secrets.authelia_storage_encryption_key.path;
      sessionSecretFile = config.sops.secrets.authelia_session_secret.path;

      # NOTE: This needs to be commented out if there are no OIDC clients present, otherwise Authelia will fail to start
      oidcHmacSecretFile = config.sops.secrets.authelia_oidc_hmac_secret.path;
      oidcIssuerPrivateKeyFile =
        config.sops.secrets.authelia_issuer_private_key.path;
    };
    settings = {
      log.level = "info";

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
        timeout = "30s";
        selection_criteria.user_verification = "preferred";
      };

      identity_providers.oidc.clients = [
        {
          client_name = "Paperless";
          client_id =
            "viHFkj_wnehAVrf2U-2cE1~RDKGEO2iawDGTJuOSLKiEt_vKBiADlhSLyjI1LsA8T6DO0Vy8";
          client_secret =
            "$pbkdf2-sha512$310000$qb7YshuNG.nvIev7OWvSyg$/nWmyxm0xxZG1mbCczkI9.Oi6lbrXd.BbsNXJU91p5nSYJGHTuN2OryQksEMK9ypCst.UYn6.q7HK/2YBstE.A";
          public = false;
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://paperless.e10.camp/accounts/oidc/authelia/login/callback/"
          ];
          scopes = [ "openid" "profile" "email" "groups" ];
          response_types = [ "code" ];
          grant_types = [ "authorization_code" ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }
        {
          client_id =
            "DpimJHTYr-K1ba5dFHj6mlRPXxkQCTN3E3RGljCmVXlGs.AcDdWwG9sysfV~Bv3vq7Z1rEEm";
          client_name = "Immich";
          client_secret =
            "$pbkdf2-sha512$310000$Fu.EoQ7p6UrQw9Z9mtY6sQ$YTh3csT6xxlXE1YotyWX2HNI0H6wRgq3x0jnkHWu93UYtHUlCRfkeBVKcbplx0sPCwBVVYeyA4gLeByyaL.iZg";
          public = false;
          authorization_policy = "two_factor";
          require_pkce = false;
          pkce_challenge_method = "";
          redirect_uris = [
            "https://immich.e10.camp/auth/login"
            "https://immich.e10.camp/user-settings"
            "app.immich:///oauth-callback"
          ];
          scopes = [ "openid" "profile" "email" ];
          response_types = [ "code" ];
          grant_types = [ "authorization_code" ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_post";
        }
      ];

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
            policy = "bypass";
            resources = [ "^/manifest.json" "^/api([/?].*)?$" ];
          }
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
            domain = "*.e10.camp";
            policy = "bypass";
            methods = [ "HEAD" ];
          }
          {
            domain = "glance.e10.camp";
            policy = "two_factor";
          }
          {
            domain = "pdf.e10.camp";
            policy = "two_factor";
          }
        ];
      };

      storage.postgres = {
        address = "unix:///run/postgresql";
        database = "authelia-${config.networking.hostName}";
        username = "authelia-${config.networking.hostName}";
        # Doesn't actually use this
        password = "authelia-${config.networking.hostName}";
      };

      session = {
        redis = {
          host = "0.0.0.0";
          port = toString
            config.services.redis.servers."authelia-${config.networking.hostName}".port;
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
        filesystem.filename =
          "/var/lib/authelia-${config.networking.hostName}/notifications.log";
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
    deps = [
      "postgresql.service"
      "redis-authelia-${config.networking.hostName}.service"
      "lldap.service"
    ];
  in {
    requires = deps;
    after = deps;
  };

  networking.firewall.allowedTCPPorts = [ 9959 ];
}
