{ config, lib, ... }: {
  sops.secrets = {
    healthchecks_secret_key = {
      sopsFile = ./secrets.json;
      owner = config.services.healthchecks.user;
    };

    healthchecks_smtp2go_password = {
      sopsFile = ./secrets.json;
      owner = config.services.healthchecks.user;
    };
  };

  services.healthchecks = {
    enable = true;
    listenAddress = "0.0.0.0";
    settings = {
      ADMINS = lib.strings.join "," [ "ethan+e10@turkeltaub.dev" ];
      SECRET_KEY_FILE = config.sops.secrets.healthchecks_secret_key.path;
      DEFAULT_FROM_EMAIL = "Healthchecks <monitor@e10.camp>";
      EMAIL_HOST = "mail.smtp2go.com";
      EMAIL_PORT = "2525";
      EMAIL_USE_TLS = "True";
      EMAIL_HOST_USER = "e10_smtp";
      EMAIL_HOST_PASSWORD_FILE = config.sops.secrets.healthchecks_smtp2go_password.path;
    };
  };
}
