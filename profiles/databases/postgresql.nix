{ config, pkgs, lib, ... }: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = lib.mkOverride 10 ''
      local all all trust
      host all all 0.0.0.0/0 trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    ensureDatabases = [ "blocky_external" "blocky_internal" ];
    ensureUsers = [
      {
        name = "blocky";
        ensurePermissions = {
          "DATABASE blocky_external" = "ALL PRIVILEGES";
          "DATABASE blocky_internal" = "ALL PRIVILEGES";
        };
      }
      {
        name = "grafana";
        ensurePermissions = {
          "DATABASE blocky_external" = "ALL PRIVILEGES";
          "DATABASE blocky_internal" = "ALL PRIVILEGES";
        };
      }
      {
        name = "root";
        ensurePermissions = {
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
    # initialScript = pkgs.writeText "postgresql-initialScript" ''
    #   CREATE ROLE blocky WITH LOGIN PASSWORD 'blocky';

    #   CREATE DATABASE blocky_external;
    #   GRANT ALL PRIVILEGES ON DATABASE blocky_external TO blocky;

    #   CREATE DATABASE blocky_internal;
    #   GRANT ALL PRIVILEGES ON DATABASE blocky_internal TO blocky;

    #   CREATE ROLE grafana WITH LOGIN PASSWORD 'grafana';
    #   GRANT READ PRIVILEGES ON DATABASE blocky_external, blocky_internal TO grafana;
    # '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];
}
