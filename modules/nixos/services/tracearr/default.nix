{ config, lib, ... }:

with lib;

let cfg = config.services.tracearr;
in {
  options.services.tracearr = {
    enable = mkEnableOption "Enable Tracearr";

    port = mkOption {
      type = types.port;
      default = 3000;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tracearr";
    };

    environment = mkOption {
      type = types.attrs;
      default = { };
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
    systemd.tmpfiles.settings."10-tracearr" = {
      ${cfg.dataDir} = {
        "d" = {
          user = config.virtualisation.oci-containers.backend;
          group = config.virtualisation.oci-containers.backend;
          mode = "0700";
        };
      };
    };

    virtualisation.oci-containers.containers.tracearr = {
      image = "ghcr.io/connorgallopo/tracearr:latest";
      environment = {
        NODE_ENV = "production";
        TZ = config.time.timeZone;
        PORT = toString 3000;
      } // cfg.environment;
      environmentFiles =
        lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      ports = [ "${toString cfg.port}:3000" ];
      volumes = [
        "${cfg.dataDir}/postgres:/data/postgres:rw"
        "${cfg.dataDir}/redis:/data/redis:rw"
        "${cfg.dataDir}/tracearr:/data/tracearr:rw"
      ];
      extraOptions = [ "--network=host" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
