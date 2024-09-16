{ profiles, pkgs, ... }: {
  imports = [ profiles.databases.postgresql.default ];

  services.postgresql = {
    initialScript = pkgs.writeText "postgres-atticd-init" ''
      CREATE ROLE atticd WITH LOGIN PASSWORD 'atticd' CREATEDB;
      CREATE DATABASE atticd;
      GRANT ALL PRIVILEGES ON DATABASE atticd TO atticd
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO atticd;
      GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO atticd;
      \c atticd postgres
      GRANT ALL ON SCHEMA public TO atticd;

      CREATE ROLE grafana WITH LOGIN PASSWORD 'grafana' CREATEDB;
      GRANT SELECT ON DATABASE atticd TO grafana;
      GRANT USAGE ON SCHEMA public TO grafana;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana;
      GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO grafana;
    '';
  };
}
