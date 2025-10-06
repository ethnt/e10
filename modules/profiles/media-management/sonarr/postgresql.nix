{ config, pkgs, lib, profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresqlBackup.databases = [ "sonarr" ];

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

  systemd = {
    services.sonarr-logs-cleanup = {
      description = "Deletes logs older than one day from sonarr_logs table";
      after = [ "postgresql.service" ];
      wants = [ "postgresql.service" ];
      serviceConfig = {
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "sonarr-logs-cleanup";
          runtimeInputs = [ config.services.postgresql.package ];
          text = ''
            sudo -u postgres psql --dbname="sonarr_logs" --command="DELETE FROM \"Logs\" WHERE \"Time\" < now() - interval '24 hours'"
          '';
        });
      };
    };

    timers.sonarr-logs-cleanup = {
      description = "Timer for sonarr-logs-cleanup service";
      timerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
