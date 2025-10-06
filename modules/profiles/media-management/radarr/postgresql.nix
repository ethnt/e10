{ lib, profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresqlBackup.databases = [ "radarr" ];

  services.postgresql = {
    ensureDatabases = [ "radarr" "radarr_logs" ];
    ensureUsers = [{
      name = "radarr";
      ensureDBOwnership = true;
    }];

    initialScriptText = lib.mkAfter ''
      ALTER DATABASE radarr_logs OWNER TO radarr;
      GRANT ALL PRIVILEGES ON DATABASE radarr_logs TO radarr;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO radarr;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO radarr;
    '';
  };
}
