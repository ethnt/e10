{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensureDBOwnership = true;
    }];
  };

  services.postgresqlBackup.databases = [ "hass" ];

  services.home-assistant = {
    extraPackages = python3Packages: with python3Packages; [ psycopg2 ];

    config.recorder = {
      db_url = "postgresql:///hass?host=/run/postgresql";
      exclude = { entities = [ "sun.sun" "sensor.date" ]; };
    };
  };
}
