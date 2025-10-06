{ lib, profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "sonarr" "sonarr_logs" ];
    ensureUsers = [{
      name = "sonarr";
      ensureDBOwnership = true;
    }];

    initialScriptText = lib.mkAfter ''
      ALTER DATABASE sonarr_logs OWNER TO sonarr;
      GRANT ALL PRIVILEGES ON DATABASE sonarr_logs TO sonarr;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sonarr;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sonarr;
    '';
  };
}
