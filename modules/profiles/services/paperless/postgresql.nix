{ config, profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [{
      name = config.services.paperless.user;
      ensureDBOwnership = true;
    }];
  };

  services.paperless.settings = {
    PAPERLESS_DBENGINE = "postgresql";
    PAPERLESS_DBHOST = "/run/postgresql";
    PAPERLESS_DBNAME = "paperless";
    PAPERLESS_DBUSER = "paperless";
  };

  systemd.services = let
    additionalServiceConfig = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  in {
    paperless-scheduler = additionalServiceConfig;
    paperless-task = additionalServiceConfig;
    paperless-consumer = additionalServiceConfig;
    paperless-web = additionalServiceConfig;
  };
}
