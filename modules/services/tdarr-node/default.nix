{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.tdarr.node;
in {
  options.services.tdarr.node = {
    enable = mkEnableOption "Enable Tdarr";

    name = mkOption {
      type = types.str;
      description = "Name of the Tdarr node";
      default = "node0";
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Tdarr files in";
      default = "/var/lib/tdarr/node";
    };

    extraVolumes = mkOption {
      type = types.listOf types.str;
      description = "Extra files to mount on the node container";
      default = [ ];
    };

    transcodeCacheDir = mkOption {
      type = types.path;
      description = "Path to store Tdarr files in";
      default = "/tmp";
    };

    serverIP = mkOption {
      type = types.str;
      description = "Port to expose for the Tdarr server";
      default = "0.0.0.0";
    };

    serverPort = mkOption {
      type = types.port;
      description = "Port to expose for the Tdarr server";
      default = 8266;
    };

    nodePort = mkOption {
      type = types.port;
      description = "Port to expose for the Tdarr node";
      default = 8268;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.tdarr_node = {
      image = "ghcr.io/haveagitgat/tdarr_node";
      environment = {
        inherit (cfg) serverIP;
        serverPort = toString cfg.serverPort;
        nodeID = cfg.name;
        TZ = config.time.timeZone;
        LD_LIBRARY_PATH = "/usr/lib/x86_64-linux-gnu";
        LIBVA_DRIVERS_PATH = "/usr/lib/x86_64-linux-gnu/dri";
        ffmpegPath = "/usr/lib/jellyfin-ffmpeg/ffmpeg";
      };
      ports = [ "${toString cfg.nodePort}:8268" ];
      volumes = [
        "${cfg.dataDir}/configs:/app/configs"
        "${cfg.dataDir}/logs:/app/logs"
        "${cfg.transcodeCacheDir}:/tmp"
      ] ++ cfg.extraVolumes;
      extraOptions = [
        "--gpus=all"
        "--network=bridge"
        "--device=/dev/dri:/dev/dri"
        "--privileged"
      ];
    };
  };
}
