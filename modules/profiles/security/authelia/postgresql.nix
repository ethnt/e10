{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    # TODO: Map instance names
    ensureDatabases = [ "authelia-bastion" ];
    ensureUsers = [{
      name = "authelia-bastion";
      ensureDBOwnership = true;
    }];
  };
}
