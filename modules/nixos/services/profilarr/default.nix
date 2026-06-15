{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.profilarr;
in {

  options.services.profilarr = {
    enable = mkEnableOption "Enable Profilarr";

    package = mkOption {
      type = types.package;
      default = pkgs.profilarr;
    };

    user = mkOption {
      type = types.str;
      default = "profilarr";
    };

    group = mkOption {
      type = types.str;
      default = "profilarr";
    };

    port = mkOption {
      type = types.port;
      default = 3474;
      description = "Port that Profilarr is running on";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/profilarr";
      description = "Data directory for Profilarr";
    };

    origin = mkOption { type = types.str; };

    parser = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Profilarr release name parser";

          package = mkOption {
            type = types.package;
            default = pkgs.profilarr-parser;
          };

          https = mkOption {
            type = types.bool;
            default = false;
          };

          listenAddress = mkOption {
            type = types.str;
            default = "localhost";
          };

          port = mkOption {
            type = types.port;
            default = 5000;
          };
        };
      };
    };

    oidc = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable OIDC";

          clientID = mkOption {
            type = types.str;
            description = "Client ID for OIDC";
          };

          clientSecretFile = mkOption {
            type = types.str;
            description = "File containing client secret for OIDC";
          };

          discoveryURL = mkOption {
            type = types.str;
            description = "Discovery URL for OIDC";
          };
        };
      };
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Profilarr";
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.profilarr = mkIf (cfg.user == "profilarr") {
        inherit (cfg) group;
        isSystemUser = true;
        home = cfg.dataDir;
        createHome = true;
        uid = 978;
      };

      groups = mkIf (cfg.group == "profilarr") { profilarr = { gid = 978; }; };
    };

    systemd.services = {
      profilarr = {
        description = "Profilarr";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        environment = {
          PUID = toString config.users.users.${cfg.user}.uid;
          PGID = toString config.users.groups.${cfg.group}.gid;
          APP_BASE_PATH = cfg.dataDir;
          PORT = toString cfg.port;
          ORIGIN = cfg.origin;
          TZ = config.time.timeZone;
        } // lib.optionalAttrs cfg.parser.enable {
          PARSER_HOST = cfg.parser.listenAddress;
          PARSER_PORT = toString cfg.parser.port;
        } // lib.optionalAttrs cfg.oidc.enable {
          AUTH = "oidc";
          OIDC_CLIENT_ID = cfg.oidc.clientID;
          OIDC_DISCOVERY_URL = cfg.oidc.discoveryURL;
        };

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "profilarr-exec-start";
            text = let
              oidcClientSecret = lib.optionalString cfg.oidc.enable ''
                export OIDC_CLIENT_SECRET

                OIDC_CLIENT_SECRET=$(cat ${cfg.oidc.clientSecretFile})
              '';
            in ''
              ${oidcClientSecret}

              ${lib.getExe' cfg.package "profilarr"}
            '';
          });
          Restart = "on-failure";
          RestartSec = 5;

          StateDirectory = "profilarr";
          StateDirectoryMode = "0750";
          WorkingDirectory = cfg.dataDir;
        };
      };

      profilarr-parser = mkIf cfg.parser.enable {
        description = "Profilarr parser";
        wantedBy = [ "multi-user.target" "profilarr.service" ];
        after = [ "network.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = let
            urls = "${
                if cfg.parser.https then "https" else "http"
              }://${cfg.parser.listenAddress}:${toString cfg.parser.port}";
          in ''
            ${lib.getExe' cfg.parser.package "profilarr-parser"} --urls ${urls}
          '';
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
