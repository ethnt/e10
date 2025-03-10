{ config, lib, ... }:

with lib;

let cfg = config.services.fileflows-node;
in {
  options.services.fileflows-node = {
    enable = mkEnableOption "Enable Fileflows processing node";

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Fileflows files in";
      default = "/var/lib/fileflows";
    };

    serverUrl = mkOption {
      type = types.str;
      description = "Fileflows server URL";
    };

    nodeName = mkOption {
      type = types.str;
      description = "Name of this processing node";
      default = "fileflows-${config.networking.hostName}-node";
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
    };

    enableIntelQuickSync = mkOption {
      type = types.bool;
      default = false;
    };

    extraVolumes = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0777 podman podman - -" ];

    virtualisation.oci-containers.containers.fileflows-node = {
      image = "revenz/fileflows:latest";
      environment = {
        TZ = config.time.timeZone;
        ServerUrl = cfg.serverUrl;
        NodeName = cfg.nodeName;
        FFNODE = "1";
      };
      volumes = [ "${cfg.dataDir}:/app/Data" ] ++ cfg.extraVolumes;
    } // lib.attrsets.optionalAttrs cfg.enableNvidia {
      environment = {
        NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
        NVIDIA_VISIBLE_DEVICES = "all";
      };

      extraOptions = [ "--device=nvidia.com/gpu=all" ];
    } // lib.attrsets.optionalAttrs cfg.enableIntelQuickSync {
      extraOptions = [ "--device=/dev/dri:/dev/dri" ];
    };
  };
}
