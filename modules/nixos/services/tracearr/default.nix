{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tracearr;
in
{
  options.services.tracearr = {
    enable = mkEnableOption "Enable Tracearr";

    package = mkOption {
      type = types.package;
      description = "Package to use for Tracearr";
      default = pkgs.tracearr;
    };

    port = mkOption {
      type = types.port;
      description = "Port to expose for Tracearr";
      default = 3000;
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory for Tracearr";
      default = "/var/lib/tracearr";
    };

    user = mkOption {
      type = types.str;
      description = "User to run Tracearr under";
      default = "tracearr";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run Tracearr under";
      default = "tracearr";
    };

    database = {
      createLocally = mkOption {
        type = types.bool;
        description = "If the Tracearr database should be created on this host. Will enable PostgreSQL";
        default = true;
      };

      enableTimescaleDB = mkOption {
        type = types.bool;
        description = "If the Tracearr database should have the TimescaleDB extension enabled";
        default = true;
      };

      name = mkOption {
        type = types.str;
        description = "Name of the database to create";
        default = "tracearr";
      };

      user = mkOption {
        type = types.str;
        description = "User that will have access to the database";
        default = "tracearr";
      };

      url = mkOption {
        type = types.str;
        description = "Database URL connection string for the database";
        default = "postgresql:///tracearr?host=/run/postgresql";
      };
    };

    redis = {
      createLocally = mkOption {
        type = types.bool;
        description = "If the Tracearr Redis instance should be created on this host";
        default = true;
      };

      name = mkOption {
        type = types.str;
        description = "Name of the Redis database to create";
        default = "tracearr";
      };

      host = mkOption {
        type = types.str;
        description = "Name of the Redis host to use";
        default = "localhost";
      };

      port = mkOption {
        type = types.port;
        description = "Port of the Redis database";
        default = 6379;
      };
    };

    oidc = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Tracearr OIDC";

          issuerUrl = mkOption {
            type = types.str;
            description = "Issuer URL of the OIDC provider";
          };

          clientId = mkOption {
            type = types.str;
            description = "The OIDC client ID";
          };

          clientSecretFile = mkOption {
            type = types.path;
            description = "Path to a file containing the OIDC client secret";
          };

          providerName = mkOption {
            type = types.str;
            description = "Name of the OIDC provider";
          };
        };
      };
    };

    corsOrigin = mkOption {
      type = types.nullOr types.str;
      description = "If behind a HTTPS reverse proxy, proxy the `X-Forwarded-Host` header, or set this option to provide an origin URL for CORS";
      default = null;
    };

    trustProxy = mkOption {
      type = types.bool;
      description = "If Tracearr should trust the forwarding proxy";
      default = false;
    };

    authSecretFile = mkOption {
      type = types.nullOr types.path;
      description = "Path to a file containing an authentication secret. Generate with `openssl rand -hex 32`";
      default = null;
    };

    cookieSecretFile = mkOption {
      type = types.path;
      description = "Path to a file containing a cookie secret. Generate with `openssl rand -hex 32`";
    };

    jwtSecretFile = mkOption {
      type = types.path;
      description = "Path to a file containing a JWT secret. Generate with `openssl rand -hex 32`";
    };

    maxmindLicenseKeyFile = mkOption {
      type = types.nullOr types.path;
      description = "Path to a file containing a MaxMind license key";
      default = null;
    };

    environment = mkOption {
      type = types.attrs;
      description = "Extra environment variables to provide to the systemd service";
      default = { };
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      description = "Extra environment file to provide to the systemd service";
      default = null;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open ports in the firewall for Tracearr";
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

    services.postgresql =
      mkIf cfg.database.createLocally {
        enable = true;
        ensureDatabases = [ cfg.database.name ];
        ensureUsers = [
          {
            name = cfg.database.user;
            ensureDBOwnership = true;
          }
        ];
      }
      // mkIf cfg.database.enableTimescaleDB {
        extensions =
          ps: with ps; [
            timescaledb
            timescaledb_toolkit
          ];
        settings = {
          shared_preload_libraries = [ "timescaledb" ];
          max_locks_per_transaction = 256;
        };
        initialScriptText = lib.mkAfter ''
          CREATE EXTENSION IF NOT EXISTS timescaledb;
          CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit;
        '';
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
      wants = [
        "network-online.target"
      ]
      ++ (lib.optional cfg.database.createLocally "postgresql.service")
      ++ (lib.optional cfg.redis.createLocally "redis-${cfg.redis.name}.service");
      after = [
        "network-online.target"
      ]
      ++ (lib.optional cfg.database.createLocally "postgresql.service")
      ++ (lib.optional cfg.redis.createLocally "redis-${cfg.redis.name}.service");
      wantedBy = [ "multi-user.target" ];
      environment = {
        DATABASE_URL =
          if cfg.database.url != null then
            cfg.database.url
          else
            (mkIf cfg.database.createLocally "postgres:///${cfg.database.name}?host=/run/postgresql&user=${cfg.database.user}");
        REDIS_URL = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
        PORT = toString cfg.port;
        APP_VERSION = cfg.package.version;
        TRUST_PROXY = lib.boolToString cfg.trustProxy;
      }
      // lib.optionalAttrs (cfg.corsOrigin != null) { CORS_ORIGIN = cfg.corsOrigin; }
      // lib.optionalAttrs cfg.oidc.enable {
        OIDC_ISSUER_URL = cfg.oidc.issuerUrl;
        OIDC_CLIENT_ID = cfg.oidc.clientId;
        OIDC_PROVIDER_NAME = cfg.oidc.providerName;
      }
      // cfg.environment;
      serviceConfig = {
        LoadCredential = [
          "cookie-secret:${cfg.cookieSecretFile}"
          "jwt-secret:${cfg.jwtSecretFile}"
        ]
        ++ lib.optional (
          cfg.maxmindLicenseKeyFile != null
        ) "maxmind-license-key:${cfg.maxmindLicenseKeyFile}"
        ++ lib.optional (cfg.authSecretFile != null) "auth-secret:${cfg.authSecretFile}"
        ++ lib.optional cfg.oidc.enable "oidc-client-secret:${cfg.oidc.clientSecretFile}";
        Environment = [
          "COOKIE_SECRET=%d/cookie-secret"
          "JWT_SECRET=%d/jwt-secret"
        ]
        ++ lib.optional (cfg.maxmindLicenseKeyFile != null) "MAXMIND_LICENSE_KEY=%d/maxmind-license-key"
        ++ lib.optional (cfg.authSecretFile != null) "BETTER_AUTH_SECRET=%d/auth-secret"
        ++ lib.optional cfg.oidc.enable "OIDC_CLIENT_SECRET=%d/oidc-client-secret";
        WorkingDirectory = cfg.dataDir;
        EnvironmentFile = [ cfg.environmentFile ];
        ExecStart = ''
          ${pkgs.lib.getExe' cfg.package "tracearr"}
        '';
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";
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

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
