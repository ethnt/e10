{ config, ... }: {
  imports = [ ./postgresql.nix ./redis.nix ];

  sops = {
    secrets = {
      paperless_admin_password = {
        sopsFile = ./secrets.yml;
        format = "yaml";
        owner = config.services.paperless.user;
      };

      paperless_socialaccount_providers = {
        sopsFile = ./secrets.yml;
        format = "yaml";
        owner = config.services.paperless.user;
      };
    };

    templates."paperless/environment_file".content = ''
      PAPERLESS_SOCIALACCOUNT_PROVIDERS='${config.sops.placeholder.paperless_socialaccount_providers}'
    '';
  };

  systemd.tmpfiles.rules = [
    "d '${config.services.paperless.dataDir}/media' 0777 ${config.services.paperless.user} nogroup - -"
    "d '${config.services.paperless.dataDir}/consume' 0777 ${config.services.paperless.user} nogroup - -"
  ];

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    passwordFile = config.sops.secrets.paperless_admin_password.path;
    dataDir = "/mnt/files/services/paperless";
    environmentFile = config.sops.templates."paperless/environment_file".path;
    settings = {
      PAPERLESS_URL = "https://paperless.e10.camp";
      USE_X_FORWARD_HOST = true;
      USE_X_FORWARD_PORT = true;
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
    };
  };
}
