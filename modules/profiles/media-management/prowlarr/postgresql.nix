{
  profiles,
  ...
}:
{
  imports = [ profiles.databases.postgresql ];

  services.postgresqlBackup.databases = [ "prowlarr" ];

  services.postgresql = {
    ensureDatabases = [
      "prowlarr"
    ];
    ensureUsers = [
      {
        name = "prowlarr";
        ensureDBOwnership = true;
      }
    ];
  };
}
