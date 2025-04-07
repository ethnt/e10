{ profiles, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    ensureDatabases = [ "lldap" ];
    ensureUsers = [{
      name = "lldap";
      ensureDBOwnership = true;
    }];
  };
}
