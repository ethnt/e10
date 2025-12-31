{ config, lib, profiles, ... }: {
  imports = [ profiles.security.authelia.default ];

  sops.secrets = let
    secretConfig = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner =
        config.services.authelia.instances.${config.networking.hostName}.user;
    };
  in {
    bastion_authelia_ldap_password = secretConfig;
    bastion_authelia_jwt_secret = secretConfig;
    bastion_authelia_storage_encryption_key = secretConfig;
    bastion_authelia_session_secret = secretConfig;
    bastion_authelia_oidc_hmac_secret = secretConfig;
    bastion_authelia_issuer_private_key = secretConfig;
  };

  services.authelia.instances.${config.networking.hostName} = {
    secrets = {
      jwtSecretFile = config.sops.secrets.bastion_authelia_jwt_secret.path;
      storageEncryptionKeyFile =
        config.sops.secrets.bastion_authelia_storage_encryption_key.path;
      sessionSecretFile =
        config.sops.secrets.bastion_authelia_session_secret.path;

      # NOTE: These need to be commented out if there are no OIDC clients present, otherwise Authelia will fail to start
      oidcHmacSecretFile =
        config.sops.secrets.bastion_authelia_oidc_hmac_secret.path;
      oidcIssuerPrivateKeyFile =
        config.sops.secrets.bastion_authelia_issuer_private_key.path;
    };

    environmentVariables.AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
      config.sops.secrets.bastion_authelia_ldap_password.path;

    settings = {
      authentication_backend.ldap = {
        address = "ldap://localhost:${
            toString config.services.lldap.settings.ldap_port
          }";
        base_dn = "dc=e10,dc=camp";
        users_filter = "(&({username_attribute}={input})(objectClass=person))";
        groups_filter = "(member={dn})";
        user = "uid=authelia,ou=people,dc=e10,dc=camp";
      };

      identity_providers.oidc = {
        claims_policies.legacy.id_token =
          [ "email" "email_verified" "preferred_username" "name" ];

        clients = [
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
          {
            client_id =
              "gY0aO8QGJT.~UbRntqa72YTm54DSUHr3HeBu4zMBlWwMwlJwLtbhXflUCAczeC-snr9I_5tZ";
            client_name = "Netbox";
            client_secret =
              "$pbkdf2-sha512$310000$Hn6tjZ1j.w4M3MK7H5rrDQ$cP1amA8.XD5kvnbgS8VOa8bcHaucuYuiS/ohdpt5gyAIHA7rN9expBt2377rkwd7qAUHO0F8YMjVPx0ihHBLKQ";
            public = false;
            authorization_policy = "two_factor";
            require_pkce = false;
            pkce_challenge_method = "";
            redirect_uris = [ "https://netbox.e10.camp/oauth/complete/oidc/" ];
            scopes = [ "openid" "profile" "email" ];
            response_types = [ "code" ];
            grant_types = [ "authorization_code" ];
            access_token_signed_response_alg = "none";
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_basic";
          }
          {
            client_id =
              "BhZjM_kfrPU38DOigEa9HToE2XTdYsmSMOxUBmUOgxLkZr4xMB45u2E8QoJYlqe3hwJMReZy";
            client_name = "Termix";
            client_secret =
              "$pbkdf2-sha512$310000$sH.OLrn2ClPUYSaNhDQgog$IZOLyiRi4qmukot3qQWwZF39z6UnuzZrJWxC6sEjslM3T8ZuRUOBfHN6y7lUuyvZB8FO2MnxG1rrHBx3wwMi/w";
            public = false;
            authorization_policy = "two_factor";
            consent_mode = "implicit";
            claims_policy = "legacy";
            grant_types = [ "authorization_code" ];
            response_types = [ "code" ];
            scopes = [ "openid" "profile" "email" ];
            redirect_uris = [ "https://termix.e10.camp/users/oidc/callback" ];
            token_endpoint_auth_method = "client_secret_post";
          }
        ];
      };

      session.cookies = [{
        domain = "e10.camp";
        authelia_url = "https://auth.e10.camp";
        inactivity = "1M";
        expiration = "3M";
        remember_me = "1y";
      }];

      access_control.rules = lib.mkBefore [
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
          domain = "glance.e10.camp";
          policy = "two_factor";
        }
        {
          domain = "pdf.e10.camp";
          policy = "two_factor";
        }
        {
          domain = "bazarr.e10.camp";
          policy = "bypass";
          resources = [ "^/api([/?].*)?$" ];
        }
        {
          domain = "bazarr.e10.camp";
          policy = "two_factor";
        }
        {
          domain = "mazanoke.e10.camp";
          policy = "two_factor";
        }
        {
          domain = "termix.e10.camp";
          policy = "two_factor";
        }
      ];
    };
  };

  systemd.services."authelia-${config.networking.hostName}" = {
    requires = [ "lldap.service" ];
    after = [ "lldap.service" ];
  };
}
