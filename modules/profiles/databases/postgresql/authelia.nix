{ config, ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ config.services.authelia.instances.main.user ];
    ensureUsers = [{
      name = config.services.authelia.instances.main.user;
      ensureDBOwnership = true;
    }];
  };
}
