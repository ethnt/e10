{ config, lib, ... }:

with lib;

let cfg = config.services.homebridge;
in {
  options.services.homebridge = {
    enable = mkEnableOption "Enable Homebridge";

    port = mkOption {
      type = types.port;
      default = 8581;
      description = "Port to use for Homebridge web interface";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/homebridge";
      description = "Directory to use for Homebridge's state";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description =
        "Whether or not to open the firewall for all ports necessary";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.homebridge = {
      image = "docker.io/homebridge/homebridge:latest";
      volumes = [ "${cfg.stateDir}:/homebridge" ];
      environment = { TZ = config.time.timeZone; };
      ports = [ "${builtins.toString cfg.port}:${builtins.toString cfg.port}" ];
      extraOptions = [
        "--privileged"
        "--net=host"
        "--label=io.containers.autoupdate=registry"
      ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port 5353 51241 ];
      allowedTCPPortRanges = [{
        from = 52100;
        to = 52150;
      }];
      allowedUDPPorts = [ cfg.port 5353 51241 ];
      allowedUDPPortRanges = [{
        from = 52100;
        to = 52150;
      }];
    };
  };
}
