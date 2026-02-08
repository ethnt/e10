{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.declutarr;
  format = pkgs.formats.yaml { };
  configFile = if cfg.config != null then
    format.generate "configuration.yaml" cfg.config
  else
    cfg.configFile;
in {
  options.services.declutarr = {
    enable = mkEnableOption "Enable Declutarr";

    package = mkOption {
      type = types.package;
      default = pkgs.declutarr;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/declutarr";
    };

    user = mkOption {
      type = types.str;
      default = "declutarr";
    };

    group = mkOption {
      type = types.str;
      default = "declutarr";
    };

    config = mkOption {
      type = types.nullOr format.type;
      default = null;
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
    assertions = [{
      assertion = !(cfg.config != null && cfg.configFile != null);
      message =
        "Only one of `config` or `configFile` can be configured at the same time";
    }];

    systemd.tmpfiles.settings."10-declutarr" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0777";
        };
      };

      "${cfg.dataDir}/config" = {
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
      users.declutarr = mkIf (cfg.user == "declutarr") {
        inherit (cfg) group;
        isSystemUser = true;
      };

      groups = mkIf (cfg.group == "declutarr") { declutarr = { }; };
    };

    systemd.services.declutarr = {
      enable = true;
      wants = [ "network.online.target" ];
      after = [ "network.online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ln -sf ${configFile} ${cfg.dataDir}/config/config.yaml
      '';
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        EnvironmentFile = [ cfg.environmentFile ];
        ExecStart = lib.getExe cfg.package;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
  };
}
