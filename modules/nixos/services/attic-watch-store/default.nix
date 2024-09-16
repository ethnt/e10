{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.attic-watch-store;
in {
  options.services.attic-watch-store = {
    enable = mkEnableOption "Enable Attic watch store daemon";

    package = mkOption {
      type = types.package;
      description = "Package to use for Attic client";
      default = pkgs.attic-client;
    };

    user = mkOption {
      type = types.str;
      description = "User to run Attic client as";
      default = "attic-watch-store";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run Attic client as";
      default = "attic-watch-store";
    };

    dataDir = mkOption {
      type = types.str;
      description = "Directory to store Attic configuration";
      default = "/var/lib/attic-watch-store";
    };

    server = mkOption {
      type = types.submodule {
        options = {
          endpoint = mkOption {
            type = types.str;
            description = "Endpoint for the Attic server";
          };

          name = mkOption {
            type = types.str;
            description = "Friendly name for this Attic server";
          };
        };
      };
    };

    cache = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the Attic cache";
          };

          authTokenFile = mkOption {
            type = types.path;
            description = "Token file containing the JWT";
          };

          netrcFile = mkOption {
            type = types.path;
            description = "Contents of the `netrc` file to use for the user";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.attic-watch-store = {
      wantedBy = [ "multi-user.target" ];
      environment.HOME = cfg.dataDir;
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        LoadCredential = "auth-token:${cfg.cache.authTokenFile}";
      };
      path = [ cfg.package ];
      script = ''
        set -eux -o pipefail

        ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/auth-token)

        attic login ${cfg.server.name} ${cfg.server.endpoint} $ATTIC_TOKEN
        attic use ${cfg.cache.name}

        exec attic watch-store ${cfg.server.name}:${cfg.cache.name}
      '';
    };

    nix.settings = {
      trusted-users = [ cfg.user ];

      netrc-file = cfg.cache.netrcFile;
    };

    users.users = mkIf (cfg.user == "attic-watch-store") {
      attic-watch-store = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
        uid = 3450;
        createHome = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "attic-watch-store") { attic-watch-store.gid = 3450; };
  };
}
