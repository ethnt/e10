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

    templates.monitor_authelia_users_file = {
      content = lib.generators.toYAML { } {
        users = {
          admin = {
            disabled = false;
            displayname = "Administrator";
            email = "admin@e10.camp";
            password =
              config.sops.placeholder.monitor_authelia_users_admin_password_hash;
          };

          ethan = {
            disabled = false;
            displayname = "Ethan Turkeltaub";
            email = "ethan@turkeltaub.me";
            password =
              config.sops.placeholder.monitor_authelia_users_ethan_password_hash;
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
      # oidcHmacSecretFile =
      #   config.sops.secrets.monitor_authelia_oidc_hmac_secret.path;
      # oidcIssuerPrivateKeyFile =
      #   config.sops.secrets.monitor_authelia_issuer_private_key.path;
    };

    settings = {
      authentication_backend.file = {
        inherit (config.sops.templates.monitor_authelia_users_file) path;
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
      ];
    };
  };
}
