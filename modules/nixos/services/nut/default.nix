{ config, lib, ... }:

with lib;

let cfg = config.services.nut;
in {
  options.services.nut = {
    enable = mkEnableOption "Enable NUT";

    user = mkOption {
      type = types.str;
      default = "nut";
    };

    group = mkOption {
      type = types.str;
      default = "nut";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/nut";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d '${cfg.stateDir}' 0700 ${cfg.user} ${cfg.group} - -" ];

    users.users = mkIf (cfg.user == "nut") {
      nut = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.stateDir;
        uid = 3094;
      };
    };

    users.groups = mkIf (cfg.group == "nut") { nut.gid = 3094; };
  };
}
