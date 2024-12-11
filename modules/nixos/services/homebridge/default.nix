{ config, lib, ... }:

with lib;

let cfg = config.services.homebridge;
in {
  options.services.homebridge = {
    enable = mkEnableOption "Enable Homebridge";

    port = mkOption {
      type = types.port;
      default = 8581;
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/homebridge";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0777 ${config.virtualisation.oci-containers.backend} ${config.virtualisation.oci-containers.backend} - -"
    ];

    virtualisation.oci-containers.containers.homebridge = {
      image = "docker.io/homebridge/homebridge:latest";
      volumes = [ "${cfg.stateDir}:/homebridge" ];
      environment = { TZ = config.time.timeZone; };
      ports = [ "${builtins.toString cfg.port}:${builtins.toString cfg.port}" ];
      extraOptions = [ "--privileged" "--net=host" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5353 cfg.port 51241 ];
      allowedTCPPortRanges = [{
        from = 52100;
        to = 52150;
      }];

      allowedUDPPorts = [ 5353 cfg.port 51241 ];
      allowedUDPPortRanges = [{
        from = 52100;
        to = 52150;
      }];
    };
  };
}
