{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "gatus" ];
    ensureUsers = [{
      name = "gatus";
      ensureDBOwnership = true;
    }];
  };

  services.postgresqlBackup.databases = [ "gatus" ];
}
