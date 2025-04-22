{ profiles, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    ensureDatabases = [ "authelia-gateway" ];
    ensureUsers = [{
      name = "authelia-gateway";
      ensureDBOwnership = true;
    }];
  };
}
