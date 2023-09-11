{ config, lib, ... }:

with lib;

let cfg = config.services.nut.server;
in {
  options.services.nut.server = {
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

    port = mkOption {
      type = types.port;
      default = 3493;
    };

    ups = mkOption {
      type = types.submodule {
        options = {
          name = mkOption { type = types.str; };

          description = mkOption { type = types.str; };

          driver = mkOption { type = types.str; };

          vendorid = mkOption { type = types.str; };

          productid = mkOption { type = types.str; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d '${cfg.stateDir}' 0700 ${cfg.user} ${cfg.group} - -" ];

    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="${cfg.ups.vendorid}", ATTRS{idProduct}=="${cfg.ups.productid}", MODE="644", GROUP="${cfg.group}", OWNER="${cfg.user}"
    '';

    power.ups = {
      enable = true;
      mode = "netserver";
      ups.${cfg.ups.name} = {
        inherit (cfg.ups) driver description;

        shutdownOrder = 0;
        port = "auto";
        directives = [
          "vendorid = ${cfg.ups.vendorid}"
          "productid = ${cfg.ups.productid}"
          "ignorelb"
          "override.battery.charge.low = 50"
          "override.battery.runtime.low = 1200"
        ];
      };
    };

    environment.etc = {
      "nut/upsd.conf" = {
        inherit (cfg) user group;

        text = ''
          LISTEN 127.0.0.1 ${toString cfg.port}
          LISTEN ::1 ${toString cfg.port}
        '';
        mode = "0440";
      };

      "nut/upsd.users" = {
        inherit (cfg) user group;

        text = ''
          [monmaster]
            password = "132010"
            upsmon master

          [monslave]
            password = "132010"
            upsmon slave
        '';
        mode = "0440";
      };

      "nut/upsmon.conf" = {
        inherit (cfg) user group;

        text = ''
          MONITOR ${cfg.ups.name}@127.0.0.1 1 monmaster "132010" master

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
    };

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
