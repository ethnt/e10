{ profiles, lib, config, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql =
    let instances = lib.attrNames config.services.authelia.instances;
    in {
      ensureDatabases = map (name: "authelia-${name}") instances;
      ensureUsers = map (name: _: {
        name = "authelia-${name}";
        ensureDBOwnership = true;
      }) instances;
    };
}
