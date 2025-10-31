{ config, lib, ... }:

with lib;

let cfg = config.services.declutarr;
in {
  options.services.declutarr = {
    enable = mkEnableOption "Enable Declutarr";

    configFile = mkOption { type = types.path; };

    extraVolumes = mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.declutarr = {
      image = "ghcr.io/manimatter/decluttarr:dev";
      environment = { TZ = config.time.timeZone; };
      volumes = [ "${cfg.configFile}:/app/config/config.yaml" ]
        ++ (map (vol: "${vol}:${vol}") cfg.extraVolumes);
    };
  };
}
