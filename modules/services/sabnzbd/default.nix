{ config, lib, ... }:

with lib;

let cfg = config.services.sabnzbd;
in {
  options.services.sabnzbd = {
    port = mkOption {
      type = types.port;
      description = "Port that sabnzbd is running on";
      default = 8080;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open ports in the firewall for the sabnzbd web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
