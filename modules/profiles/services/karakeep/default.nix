{ config, ... }: {
  sops = {
    secrets = {
      karakeep_nextauth_secret.sopsFile = ./secrets.json;
      karakeep_oauth_secret.sopsFile = ./secrets.json;
    };

    templates.karakeep_environment_file = {
      content = ''
        NEXTAUTH_SECRET=${config.sops.placeholder.karakeep_nextauth_secret}
        OAUTH_CLIENT_SECRET=${config.sops.placeholder.karakeep_oauth_secret}
      '';
      owner = "karakeep";
    };
  };

  systemd.tmpfiles.settings."10-karakeep" = {
    ${config.services.karakeep.extraEnvironment.DATA_DIR} = {
      "d" = {
        user = "karakeep";
        group = "karakeep";
        mode = "0700";
      };
    };
  };

  services.karakeep = {
    enable = true;
    browser.enable = true;
    meilisearch.enable = true;
    extraEnvironment = {
      PORT = "4900";
      DATA_DIR = "/var/lib/karakeep";

      DISABLE_SIGNUPS = "true";
      DISABLE_PASSWORD_AUTH = "true";

      NEXTAUTH_URL = "https://karakeep.e10.camp";

      OAUTH_WELLKNOWN_URL =
        "https://auth.e10.camp/.well-known/openid-configuration";
      OAUTH_CLIENT_ID =
        "4_PUhlKbm03-XaIAR-tBOzaCkf6dQfhgBY-xnrewL5jsOCp0UXPsbSvnaxgLXEp6kKsqjqND";
      OAUTH_PROVIDER_NAME = "Authelia";
      OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
    };
    environmentFile = config.sops.templates.karakeep_environment_file.path;
  };
}
