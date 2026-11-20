{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.multi-scrobbler;
in
{
  options.services.multi-scrobbler = {
    enable = mkEnableOption "multi-scrobbler";

    package = mkOption {
      type = types.package;
      default = pkgs.multi-scrobbler;
    };

    user = mkOption {
      type = types.str;
      default = "multi-scrobbler";
    };

    group = mkOption {
      type = types.str;
      default = "multi-scrobbler";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/multi-scrobbler";
    };

    port = mkOption {
      type = types.port;
      default = 9078;
    };

    baseUrl = mkOption {
      type = types.str;
      default = "http://localhost:${toString cfg.port}";
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
    systemd.tmpfiles.settings."10-multi-scrobbler" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0777";
        };
      };

      "${cfg.dataDir}/data" = {
        "d" = {
          inherit (cfg) user group;
          mode = "0777";
        };
      };

      "${cfg.dataDir}/logs" = {
        "d" = {
          inherit (cfg) user group;
          mode = "0777";
        };
      };
    };

    users = {
      users = mkIf (cfg.user == "multi-scrobbler") {
        multi-scrobbler = {
          isSystemUser = true;
          home = cfg.dataDir;
          inherit (cfg) group;
        };
      };

      groups = mkIf (cfg.group == "multi-scrobbler") { multi-scrobbler = { }; };
    };

    systemd.services.multi-scrobbler = {
      enable = true;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        CONFIG_DIR = cfg.dataDir;
        DATA_DIR = "${cfg.dataDir}/data";
        LOGS_DIR = "${cfg.dataDir}/logs";
        BASE_URL = cfg.baseUrl;
      };
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        ExecStart = lib.getExe cfg.package;
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;
  };
}
