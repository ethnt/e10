{ config, lib, profiles, ... }: {
  imports = [ profiles.security.authelia.default ];

  sops = {
    secrets = let
      secretConfig = {
        sopsFile = ./secrets.yml;
        format = "yaml";
        owner =
          config.services.authelia.instances.${config.networking.hostName}.user;
      };
    in {
      monitor_authelia_jwt_secret = secretConfig;
      monitor_authelia_storage_encryption_key = secretConfig;
      monitor_authelia_session_secret = secretConfig;
      monitor_authelia_oidc_hmac_secret = secretConfig;
      monitor_authelia_issuer_private_key = secretConfig;
      monitor_authelia_users_admin_password_hash = secretConfig;
      monitor_authelia_users_ethan_password_hash = secretConfig;
      monitor_authelia_users_gatus_password_hash = secretConfig;
    };

    templates."authelia/users.yml" = {
      content = lib.generators.toYAML { } {
        users = {
          admin = {
            disabled = false;
            displayname = "Administrator";
            email = "admin@e10.camp";
            password =
              config.sops.placeholder.monitor_authelia_users_admin_password_hash;
            groups = [ "admin" ];
          };

          ethan = {
            disabled = false;
            displayname = "Ethan Turkeltaub";
            email = "ethan@turkeltaub.me";
            password =
              config.sops.placeholder.monitor_authelia_users_ethan_password_hash;
            groups = [ "admin" ];
          };

          gatus = {
            disabled = false;
            displayname = "Gatus";
            email = "monitor@e10.camp";
            password =
              config.sops.placeholder.monitor_authelia_users_gatus_password_hash;
            groups = [ "service" ];
          };
        };
      };
      owner =
        config.services.authelia.instances.${config.networking.hostName}.user;
    };
  };

  services.authelia.instances.${config.networking.hostName} = {
    secrets = {
      jwtSecretFile = config.sops.secrets.monitor_authelia_jwt_secret.path;
      storageEncryptionKeyFile =
        config.sops.secrets.monitor_authelia_storage_encryption_key.path;
      sessionSecretFile =
        config.sops.secrets.monitor_authelia_session_secret.path;

      # NOTE: These need to be commented out if there are no OIDC clients present, otherwise Authelia will fail to start
      oidcHmacSecretFile =
        config.sops.secrets.monitor_authelia_oidc_hmac_secret.path;
      oidcIssuerPrivateKeyFile =
        config.sops.secrets.monitor_authelia_issuer_private_key.path;
    };

    settings = {
      authentication_backend.file = {
        inherit (config.sops.templates."authelia/users.yml") path;
        watch = false;
        password = {
          algorithm = "argon2";
          argon2 = {
            variant = "argon2id";
            iterations = 3;
            memory = 65536;
            parallelism = 4;
            key_length = 32;
            salt_length = 16;
          };
        };
      };

      session.cookies = [{
        domain = "e10.camp";
        authelia_url = "https://auth.monitor.e10.camp";
        inactivity = "1M";
        expiration = "3M";
        remember_me = "1y";
      }];

      identity_providers.oidc = {
        claims_policies = {
          grafana.id_token = [ "email" "name" "groups" "preferred_username" ];
        };

        clients = [{
          client_id =
            "1vukV4u1uEh~p-HGYBHhB-xv.ZyyKW3tI2Cco5F1f_jaI9Qamn_oc4rLoy7nqx3h3IwnsB5.";
          client_name = "Grafana";
          claims_policy = "grafana";
          client_secret =
            "$pbkdf2-sha512$310000$IT.5orFA6bKiL/AWi.rP5Q$oDajcRBqmnCuZZxa6L1/o3BrfQDPYAS/YOl2e2dIGbyoXaRTgNptf66ah6NHpwgGNm/hyAvuYHej3.jybdsvUQ";
          public = false;
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://grafana.e10.camp/login/generic_oauth" ];
          scopes = [ "openid" "profile" "groups" "email" ];
          response_types = [ "code" ];
          grant_types = [ "authorization_code" ];
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_basic";
        }];
      };

      access_control.rules = lib.mkAfter [
        {
          domain = "*.e10.camp";
          policy = "bypass";
          methods = [ "HEAD" ];
        }
        {
          domain = "*.e10.camp";
          policy = "one_factor";
          subject = [ "group:service" ];
        }
        {
          domain = "*.e10.camp";
          policy = "two_factor";
        }
      ];
    };
  };

  provides.services.authelia = {
    name = "Authelia (Monitor)";
    http = {
      port = 9091;
      proxy = {
        enable = true;
        domain = "auth.monitor.e10.camp";
        extraConfig = ''
          header Access-Control-Allow-Origin "*"
        '';
      };
    };
  };
}
