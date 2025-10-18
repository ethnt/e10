{ config, lib, ... }:

with lib;

let cfg = config.services.mazanoke;
in {
  options.services.mazanoke = {
    enable = mkEnableOption "Enable Mazanoke";

    port = mkOption {
      type = types.port;
      default = 3474;
      description = "Port that Mazanoke is running on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Mazanoke";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.mazanoke = {
      image = "ghcr.io/civilblur/mazanoke:latest";
      ports = [ "${toString cfg.port}:80" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
