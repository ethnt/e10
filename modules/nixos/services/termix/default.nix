{ config, lib, ... }:

with lib;

let cfg = config.services.termix;
in {
  options.services.termix = {
    enable = mkEnableOption "Enable Termix";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/termix";
    };

    port = mkOption {
      type = types.port;
      default = 8095;
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-termix" = {
      "${cfg.dataDir}" = {
        "d" = {
          user = config.virtualisation.oci-containers.backend;
          group = config.virtualisation.oci-containers.backend;
          mode = "0700";
        };
      };
    };

    virtualisation.oci-containers.containers.termix = {
      image = "ghcr.io/lukegus/termix:latest";
      environment = {
        PORT = toString cfg.port;
        TZ = config.time.timeZone;
        ENABLE_SSL = toString false;
      };
      environmentFiles =
        lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      volumes = [ "${cfg.dataDir}:/app/data:rw" ];
      ports = [ "${toString cfg.port}:8095" ];
    };
  };
}
