{
  profiles,
  ...
}:
{
  imports = [ profiles.databases.postgresql ];

  services.postgresqlBackup.databases = [ "radarr" ];

  services.postgresql = {
    ensureDatabases = [
      "radarr"
    ];
    ensureUsers = [
      {
        name = "radarr";
        ensureDBOwnership = true;
      }
    ];
  };
}
