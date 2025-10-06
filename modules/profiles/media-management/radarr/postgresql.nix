{ config, pkgs, lib, profiles, ... }: {
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

  systemd = {
    services.radarr-logs-cleanup = {
      description = "Deletes logs older than one day from radarr_logs table";
      after = [ "postgresql.service" ];
      wants = [ "postgresql.service" ];
      serviceConfig = {
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "radarr-logs-cleanup";
          runtimeInputs = [ config.services.postgresql.package ];
          text = ''
            sudo -u postgres psql --dbname="radarr_logs" --command="DELETE FROM \"Logs\" WHERE \"Time\" < now() - interval '24 hours'"
          '';
        });
      };
    };

    timers.radarr-logs-cleanup = {
      description = "Timer for radarr-logs-cleanup service";
      timerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
