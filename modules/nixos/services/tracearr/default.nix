{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.tracearr;
in {
  options.services.tracearr = {
    enable = mkEnableOption "Enable Tracearr";

    package = mkOption {
      type = types.package;
      default = pkgs.tracearr;
    };

    port = mkOption {
      type = types.port;
      default = 3000;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tracearr";
    };

    user = mkOption {
      type = types.str;
      default = "tracearr";
    };

    group = mkOption {
      type = types.str;
      default = "tracearr";
    };

    database = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
      };

      enableTimescaleDB = mkOption {
        type = types.bool;
        default = true;
      };

      name = mkOption {
        type = types.str;
        default = "tracearr";
      };

      user = mkOption {
        type = types.str;
        default = "tracearr";
      };

      url = mkOption {
        type = types.str;
        default = "postgresql:///tracearr?host=/run/postgresql";
      };
    };

    redis = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
      };

      name = mkOption {
        type = types.str;
        default = "tracearr";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
      };

      port = mkOption {
        type = types.port;
        default = 6379;
      };
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-tracearr" = {
      ${cfg.dataDir} = {
        "d" = {
          user = "tracearr";
          group = "tracearr";
          mode = "0700";
        };
      };
    };

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = cfg.database.user;
        ensureDBOwnership = true;
      }];
    } // mkIf cfg.database.enableTimescaleDB {
      extensions = ps: with ps; [ timescaledb ];
      settings = { shared_preload_libraries = [ "timescaledb" ]; };
    };

    services.redis = mkIf cfg.redis.createLocally {
      servers.${cfg.redis.name} = {
        enable = true;
        bind = "localhost";
        inherit (cfg.redis) port;
      };
    };

    systemd.services.tracearr = {
      enable = true;
      wants = [ "network-online.target" ]
        ++ (lib.optional cfg.database.createLocally "postgresql.service")
        ++ (lib.optional cfg.redis.createLocally
          "redis-${cfg.redis.name}.service");
      after = [ "network-online.target" ]
        ++ (lib.optional cfg.database.createLocally "postgresql.service")
        ++ (lib.optional cfg.redis.createLocally
          "redis-${cfg.redis.name}.service");
      wantedBy = [ "multi-user.target" ];
      environment = {
        DATABASE_URL = if cfg.database.url != null then
          cfg.database.url
        else
          (mkIf cfg.database.createLocally
            "postgres:///${cfg.database.name}?host=/run/postgresql&user=${cfg.database.user}");
        REDIS_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
        PORT = toString cfg.port;
        APP_VERSION = cfg.package.version;
      };
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        EnvironmentFile = [ cfg.environmentFile ];
        ExecStart = ''
          ${pkgs.lib.getExe' cfg.package "tracearr"}
        '';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
    };

    users = {
      users.${cfg.user} = {
        isSystemUser = true;
        inherit (cfg) group;
      };
      groups.${cfg.group} = { };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
