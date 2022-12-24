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
    virtualisation.oci-containers.containers.overseerr = {
      image = "sctx/overseerr";
      environment = {
        LOG_LEVEL = "debug";
        TZ = config.time.timeZone;
      };
      ports = [ "${toString cfg.port}:5055" ];
      volumes = [ "${cfg.dataDir}:/app/config" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
