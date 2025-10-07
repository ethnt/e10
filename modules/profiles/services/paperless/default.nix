{ config, ... }: {
  imports = [ ./postgresql.nix ./redis.nix ];

  sops.secrets = {
    paperless_admin_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.paperless.user;
    };
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
    settings = {
      PAPERLESS_URL = "https://paperless.e10.camp";
      USE_X_FORWARD_HOST = true;
      USE_X_FORWARD_PORT = true;
    };
  };
}
