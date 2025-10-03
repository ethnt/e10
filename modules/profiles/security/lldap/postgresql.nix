{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "lldap" ];
    ensureUsers = [{
      name = "lldap";
      ensureDBOwnership = true;
    }];
  };
}
