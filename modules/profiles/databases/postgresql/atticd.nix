{ pkgs, ... }: {
  services.postgresql = {
    initialScript = pkgs.writeText "postgres-atticd-init" ''
      CREATE ROLE atticd WITH LOGIN PASSWORD 'atticd' CREATEDB;
      CREATE DATABASE atticd;
      GRANT ALL PRIVILEGES ON DATABASE atticd TO atticd;
    '';
  };
}
