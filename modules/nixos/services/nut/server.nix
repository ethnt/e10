{ config, lib, ... }:

with lib;

let cfg = config.services.nut.server;
in {
  options.services.nut.server = {
    enable = mkEnableOption "Enable NUT";

    user = mkOption {
      type = types.str;
      default = "nut";
      description = "User to run NUT services under";
    };

    group = mkOption {
      type = types.str;
      default = "nut";
      description = "Group to run NUT services under";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/nut";
      description = "Directory to use for NUT state";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host to listen on";
    };

    port = mkOption {
      type = types.port;
      default = 3493;
      description = "Port to expose NUT on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to open the firewall on the given port";
    };

    ups = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name (machine-readable) of the UPS";
          };

          description = mkOption {
            type = types.str;
            description = "Description (human-readable) of the UPS";
          };

          driver = mkOption {
            type = types.str;
            default = "usbhid-ups";
            description = "NUT driver to use for this UPS";
          };

          vendorid = mkOption {
            type = types.str;
            description = "USB vendor ID of the UPS";
          };

          productid = mkOption {
            type = types.str;
            description = "USB product ID of the UPS";
          };

          extraDirectives = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Extra directives to add to ups.conf";
          };
        };
      };
      description = "UPS configuration";
    };

    users = mkOption {
      type = types.submodule {
        options = {
          leader = mkOption {
            type = types.submodule {
              options = {
                username = mkOption {
                  type = types.str;
                  default = "leader";
                  description = "Username for this UPS user";
                };

                password = mkOption {
                  type = types.str;
                  default = "";
                  description = "Password for this UPS user";
                };
              };
            };
          };

          follower = mkOption {
            type = types.submodule {
              options = {
                username = mkOption {
                  type = types.str;
                  default = "follower";
                  description = "Username for this UPS user";
                };

                password = mkOption {
                  type = types.str;
                  default = "";
                  description = "Password for this UPS user";
                };
              };
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0700 ${cfg.user} ${cfg.group} - -"
      "d '/var/state/ups' 0700 ${cfg.user} ${cfg.group} - -"
    ];

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
        ] ++ cfg.ups.extraDirectives;
      };
    };

    environment.etc = {
      "nut/upsd.conf" = {
        inherit (cfg) user group;

        text = ''
          LISTEN ${cfg.host} ${toString cfg.port}
        '';
        mode = "0440";
      };

      "nut/upsd.users" = {
        inherit (cfg) user group;

        text = ''
          [${cfg.users.leader.username}]
            password = "${cfg.users.leader.password}"
            upsmon master

          [${cfg.users.follower.username}]
            password = "${cfg.users.follower.password}"
            upsmon slave
        '';
        mode = "0440";
      };

      "nut/upsmon.conf" = {
        inherit (cfg) user group;

        text = ''
          MONITOR ${cfg.ups.name}@${cfg.host}:${
            toString cfg.port
          } 1 ${cfg.users.leader.username} "${cfg.users.leader.password}" master

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
