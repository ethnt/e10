{ config, lib, ... }:

with lib;

let cfg = config.services.fileflows-server;
in {
  options.services.fileflows-server = {
    enable = mkEnableOption "Enable Fileflows server";

    port = mkOption {
      type = types.port;
      description = "Port for Fileflows to listen on";
      default = 19200;
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Fileflows files in";
      default = "/var/lib/fileflows";
    };

    openFirewall = mkOption {
      type = types.bool;
      description =
        "Open ports in the firewall for the Fileflows web interface";
      default = false;
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
    };

    extraVolumes = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0777 ${config.virtualisation.oci-containers.backend} ${config.virtualisation.oci-containers.backend} - -"
    ];

    virtualisation.oci-containers.containers.fileflows-server = {
      image = "revenz/fileflows:latest";
      environment = { TZ = config.time.timeZone; };
      ports = [ "${toString cfg.port}:5000" ];
      volumes = [ "${cfg.dataDir}:/app/Data" ] ++ cfg.extraVolumes;
    } // lib.attrsets.optionalAttrs cfg.enableNvidia {
      environment = {
        NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
        NVIDIA_VISIBLE_DEVICES = "all";
      };

      extraOptions = [ "--device=nvidia.com/gpu=all" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
