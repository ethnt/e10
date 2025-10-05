{ profiles, lib, config, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = let instances = config.services.authelia.instances;
  in {
    ensureDatabases =
      lib.attrsets.mapAttrsToList (name: _: "authelia-${name}") instances;
    ensureUsers = lib.attrsets.mapAttrsToList (name: _: {
      name = "authelia-${name}";
      ensureDBOwnership = true;
    }) instances;
  };
}
