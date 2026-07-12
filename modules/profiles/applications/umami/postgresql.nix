{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "umami" ];
    ensureUsers = [
      {
        name = "umami";
        ensureDBOwnership = true;
      }
    ];
  };
}
