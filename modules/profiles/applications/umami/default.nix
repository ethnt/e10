{ config, ... }: {
  imports = [ ./postgresql.nix ];

  sops.secrets = {
    umami_app_secret = {
      sopsFile = ./secrets.json;
    };
  };

  services.umami = {
    enable = true;
    createPostgresqlDatabase = false;
    settings = {
      HOSTNAME = "0.0.0.0";
      PORT = 3010;
      DATABASE_URL = "postgresql://localhost/umami?host=/run/postgresql";
      APP_SECRET_FILE = config.sops.secrets.umami_app_secret.path;
    };
  };
}
