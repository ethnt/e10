{ config, profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    ensureDatabases = [ "crowdsec" ];
    ensureUsers = [
      {
        name = "crowdsec";
        ensureDBOwnership = true;
      }
    ];
  };

  services.crowdsec.settings.config.db_config = {
    type = "postgresql";
    user = "crowdsec";
    password = "crowdsec";
    db_name = "crowdsec";
    host = "/run/postgresql";
    port = 5432;
  };

  systemd.services.crowdsec = {
    requires = [ "postgresql.target" ];
    after = [ "postgresql.target" ];
  };

  systemd.services."crowdsec-grafana-db-grants" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "postgresql.target" ];
    requires = [ "postgresql.target" ];
    environment.PGPORT = toString config.services.postgresql.settings.port;
    path = [ config.services.postgresql.package ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      psql -v ON_ERROR_STOP=1 crowdsec <<'EOF'
        DO $$ BEGIN
          IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'grafana') THEN
            CREATE ROLE grafana WITH LOGIN PASSWORD 'grafana';
          END IF;
        END $$;
        GRANT CONNECT ON DATABASE crowdsec TO grafana;
        GRANT USAGE ON SCHEMA public TO grafana;
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana;
        GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO grafana;
        ALTER DEFAULT PRIVILEGES FOR ROLE crowdsec IN SCHEMA public GRANT SELECT ON TABLES TO grafana;
        ALTER DEFAULT PRIVILEGES FOR ROLE crowdsec IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO grafana;
      EOF
    '';
  };
}
