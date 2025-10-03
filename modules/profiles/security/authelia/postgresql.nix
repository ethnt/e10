{ profiles, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    ensureDatabases = [ "authelia-bastion" ];
    ensureUsers = [{
      name = "authelia-bastion";
      ensureDBOwnership = true;
    }];
  };
}
