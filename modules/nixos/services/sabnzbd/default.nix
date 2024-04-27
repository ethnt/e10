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
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
