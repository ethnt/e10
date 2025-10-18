{ config, ... }: {
  imports = [ ./postgresql.nix ./redis.nix ];

  sops.secrets = let
    secretConfig = {
      sopsFile = ./secrets.json;
      owner =
        config.services.authelia.instances.${config.networking.hostName}.user;
    };
  in {
    authelia_ldap_password = secretConfig;
    authelia_aws_ses_smtp_username = secretConfig;
    authelia_aws_ses_smtp_password = secretConfig;
  };

  services.authelia.instances.${config.networking.hostName} = {
    enable = true;
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

      access_control = {
        default_policy = "bypass";

        networks = [{
          name = "internal";
          networks =
            [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/18" "100.0.0.0/8" ];
        }];
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
