{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.tdarr.server;
in {
  options.services.tdarr.server = {
    enable = mkEnableOption "Enable Tdarr";

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Tdarr files in";
      default = "/var/lib/tdarr/server";
    };

    extraVolumes = mkOption {
      type = types.listOf types.str;
      description = "Extra files to mount on the server container";
      default = [ ];
    };

    transcodeCacheDir = mkOption {
      type = types.path;
      description = "Path to store Tdarr files in";
      default = "/tmp";
    };

    serverPort = mkOption {
      type = types.port;
      description = "Port to expose for the Tdarr server";
      default = 8265;
    };

    webUIPort = mkOption {
      type = types.port;
      description = "Port to expose for the Tdarr Web UI server";
      default = 8266;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open ports in the firewall for the Tdarr web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.tdarr_server = {
      image = "ghcr.io/haveagitgat/tdarr";
      environment = {
        serverIP = "0.0.0.0";
        serverPort = "8266";
        webUIPort = "8265";
        internalNode = "true";
        nodeID = "InternalNode";
        TZ = config.time.timeZone;
      };
      ports =
        [ "${toString cfg.serverPort}:8265" "${toString cfg.webUIPort}:8266" ];
      volumes = [
        "${cfg.dataDir}/server:/app/server"
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

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.serverPort cfg.webUIPort ];
    };
  };
}
