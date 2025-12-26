{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "tracearr" ];
    ensureUsers = [{
      name = "tracearr";
      ensureDBOwnership = true;
    }];
  };
}
