{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.recyclarr;
  configFile = if cfg.configFile == null then
    pkgs.writeText "recyclarr.yaml" (builtins.writeJSON cfg.config)
  else
    cfg.configFile;
in {
  options.services.recyclarr = {
    enable = mkEnableOption "Enable Recyclarr";

    package = mkOption {
      type = types.package;
      default = pkgs.recyclarr;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/recyclarr";
    };

    user = mkOption {
      type = types.str;
      default = "recyclarr";
    };

    group = mkOption {
      type = types.str;
      default = "recyclarr";
    };

    config = mkOption {
      type = types.attrs;
      default = { };
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -" ];

    systemd.services.recyclarr = {
      description = "Recyclarr Sync Service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe cfg.package} sync --config ${configFile}";
        EnvironmentFile =
          mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    systemd.timers.recyclarr = {
      description = "Recyclarr Sync Timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = [ "daily" ];
        Persistent = true;
      };
    };

    users.users = mkIf (cfg.user == "recyclarr") {
      recyclarr = {
        inherit (cfg) group;
        uid = 330;
        home = cfg.dataDir;
      };
    };

    users.groups =
      mkIf (cfg.group == "recyclarr") { recyclarr = { gid = 330; }; };
  };
}
