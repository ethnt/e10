{ profiles, pkgs, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    initialScript = pkgs.writeText "postgres-blocky-init" ''
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
}
