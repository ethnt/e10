{ config, lib, ... }: {
  sops.secrets = let
    secretConfig = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner =
        config.services.authelia.instances.${config.networking.hostName}.user;
    };
  in {
    authelia_jwt_secret = secretConfig;
    authelia_storage_encryption_key = secretConfig;
    authelia_session_secret = secretConfig;
    authelia_oidc_hmac_secret = secretConfig;
    authelia_issuer_private_key = secretConfig;
  };

  services.authelia.instances.${config.networking.hostName} = {
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
      ];

      access_control.rules = lib.mkAfter [
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
        {
          domain = "bazarr.e10.camp";
          policy = "two_factor";
        }
        {
          domain = "mazanoke.e10.camp";
          policy = "two_factor";
        }
      ];
    };
  };
}
