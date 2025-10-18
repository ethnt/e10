{ config, lib, ... }:

with lib;

let cfg = config.services.profilarr;
in {

  options.services.profilarr = {
    enable = mkEnableOption "Enable Profilarr";

    port = mkOption {
      type = types.port;
      default = 3474;
      description = "Port that Profilarr is running on";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/profilarr";
      description = "Data directory for Profilarr";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Profilarr";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      "10-profilarr" = {
        ${cfg.dataDir} = {
          d = {
            group = config.virtualisation.oci-containers.backend;
            user = config.virtualisation.oci-containers.backend;
            mode = "0777";
          };
        };
      };
    };

    virtualisation.oci-containers.containers.profilarr = {
      image = "santiagosayshey/profilarr:latest";
      ports = [ "${toString cfg.port}:6868" ];
      volumes = [ "${cfg.dataDir}:/config" ];
      environment.TZ = config.time.timeZone;
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
