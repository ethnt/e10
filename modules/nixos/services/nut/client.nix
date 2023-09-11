{ config, lib, ... }:

with lib;

let cfg = config.services.nut.client;
in {
  options.services.nut.client = {
    enable = mkEnableOption "Enable NUT client";

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

    power.ups = {
      enable = true;
      mode = "netclient";
    };

    environment.etc."nut/upsmon.conf" = {
      inherit (cfg) user group;

      text = ''
        MONITOR tripplite@192.168.10.31 1 monslave "132010" slave

        RUN_AS_USER root

        MINSUPPLIES 1
        SHUTDOWNCMD "/run/current-system/sw/bin/shutdown -h +0"
        NOTIFYCMD /run/current-system/sw/bin/upssched
        POLLFREQ 5
        POLLFREQALERT 5
        HOSTSYNC 15
        DEADTIME 15
        POWERDOWNFLAG /etc/killpower

        NOTIFYMSG ONLINE  "UPS %s on line power"
        NOTIFYMSG ONBATT  "UPS %s on battery"
        NOTIFYMSG LOWBATT "UPS %s battery is low"
        NOTIFYMSG FSD   "UPS %s: forced shutdown in progress"
        NOTIFYMSG COMMOK  "Communications with UPS %s established"
        NOTIFYMSG COMMBAD "Communications with UPS %s lost"
        NOTIFYMSG SHUTDOWN  "Auto logout and shutdown proceeding"
        NOTIFYMSG REPLBATT  "UPS %s battery needs to be replaced"
        NOTIFYMSG NOCOMM  "UPS %s is unavailable"
        NOTIFYMSG NOPARENT  "upsmon parent process died - shutdown impossible"

        NOTIFYFLAG ONLINE SYSLOG+WALL+EXEC
        NOTIFYFLAG ONBATT SYSLOG+WALL+EXEC
        NOTIFYFLAG LOWBATT  SYSLOG+WALL+EXEC
        NOTIFYFLAG FSD    SYSLOG+WALL+EXEC
        NOTIFYFLAG COMMOK SYSLOG+WALL+EXEC
        NOTIFYFLAG COMMBAD  SYSLOG+WALL+EXEC
        NOTIFYFLAG SHUTDOWN SYSLOG+WALL+EXEC
        NOTIFYFLAG REPLBATT SYSLOG+WALL+EXEC
        NOTIFYFLAG NOCOMM SYSLOG+WALL+EXEC
        NOTIFYFLAG NOPARENT SYSLOG+WALL

        RBWARNTIME 43200

        NOCOMMWARNTIME 300

        FINALDELAY 5
      '';
      mode = "0444";
    };

    systemd.services.upsd.enable = false;
    systemd.services.upsdrv.enable = false;

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
