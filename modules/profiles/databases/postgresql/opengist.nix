{ profiles, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    ensureDatabases = [ "opengist" ];
    ensureUsers = [{
      name = "opengist";
      ensureDBOwnership = true;
    }];
  };
}
