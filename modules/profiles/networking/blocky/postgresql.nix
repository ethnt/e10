{ profiles, ... }: {
  imports = [ profiles.databases.postgresql ];

  services.postgresql = {
    initialScriptText = ''
      CREATE ROLE blocky WITH LOGIN PASSWORD 'blocky' CREATEDB;
      CREATE DATABASE blocky;
      GRANT ALL PRIVILEGES ON DATABASE blocky TO blocky
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO blocky;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO blocky;
      \c blocky postgres
      GRANT ALL ON SCHEMA public TO blocky;

      CREATE ROLE grafana WITH LOGIN PASSWORD 'grafana' CREATEDB;
      GRANT SELECT ON DATABASE blocky TO grafana;
      GRANT USAGE ON SCHEMA public TO grafana;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana;
      GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO grafana;
    '';
  };

  services.blocky.settings.queryLog = {
    type = "postgresql";
    target = "postgres://blocky:blocky@localhost:5432/blocky";
    logRetentionDays = 90;
    flushInterval = "5s";
  };

  systemd.services.blocky = {
    after = [ "postgresql.service" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1";
    };
  };
}
