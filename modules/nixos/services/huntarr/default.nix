{ config, lib, ... }:

with lib;

let cfg = config.services.huntarr;
in {
  options.services.huntarr = {
    enable = mkEnableOption "Enable Huntarr";

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Huntarr files in";
      default = "/var/lib/huntarr";
    };

    port = mkOption {
      type = types.port;
      default = 9705;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0777 ${config.virtualisation.oci-containers.backend} ${config.virtualisation.oci-containers.backend} - -"
    ];

    virtualisation.oci-containers.containers.huntarr = {
      image = "huntarr/huntarr:latest";
      environment = { TZ = config.time.timeZone; };
      ports = [ "${toString cfg.port}:9705" ];
      volumes = [ "${cfg.dataDir}:/config" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
