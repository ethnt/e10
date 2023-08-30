{ config, lib, ... }:

with lib;

let cfg = config.services.overseerr;
in {
  options.services.overseerr = {
    enable = mkEnableOption "Enable Overseerr";

    port = mkOption {
      type = types.port;
      description = "Port for Overseerr to listen on";
      default = 5055;
    };

    user = mkOption {
      type = types.str;
      description = "User to run Overseerr";
      default = "overseerr";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run Overseerr";
      default = "overseerr";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Overseerr files in";
      default = "/var/lib/overseerr";
    };

    openFirewall = mkOption {
      type = types.bool;
      description =
        "Open ports in the firewall for the Overseerr web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0777 nobody nogroup - -" ];

    # users.users = mkIf (cfg.user == "overseerr") {
    #   overseerr = {
    #     group = cfg.group;
    #     home = cfg.dataDir;
    #     uid = 401;
    #   };
    # };

    # users.groups = mkIf (cfg.group == "overseerr") { overseerr.gid = 401; };

    virtualisation.oci-containers.containers.overseerr = {
      image = "sctx/overseerr";
      environment = {
        LOG_LEVEL = "debug";
        TZ = config.time.timeZone;
      };
      ports = [ "${toString cfg.port}:5055" ];
      volumes = [ "${cfg.dataDir}:/app/config" ];
      # user = "${cfg.user}:${cfg.group}";
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
