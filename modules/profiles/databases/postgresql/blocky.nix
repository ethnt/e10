{ pkgs, ... }: {
  services.postgresql = {
    initialScript = pkgs.writeText "postgres-blocky-init" ''
      CREATE ROLE blocky WITH LOGIN PASSWORD 'blocky' CREATEDB;
      CREATE DATABASE blocky;
      GRANT ALL PRIVILEGES ON DATABASE blocky TO blocky;

      CREATE ROLE grafana WITH LOGIN PASSWORD 'grafana' CREATEDB;
      GRANT SELECT ON DATABASE blocky TO grafana;
    '';
  };
}
