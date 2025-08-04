{ config, lib, ... }:

with lib;

let cfg = config.services.wizarr;

in {
  options.services.wizarr = {
    enable = mkEnableOption "Enable Wizarr";

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Wizarr files in";
      default = "/var/lib/wizarr";
    };

    port = mkOption {
      type = types.port;
      default = 5690;
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

    virtualisation.oci-containers.containers.wizarr = {
      image = "ghcr.io/wizarrrr/wizarr";
      environment = { TZ = config.time.timeZone; };
      ports = [ "${toString cfg.port}:5690" ];
      volumes = [ "${cfg.dataDir}:/data/database" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
