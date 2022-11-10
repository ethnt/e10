{ config, lib, ... }:

with lib;

let cfg = config.services.bazarr;
in {
  disabledModules = [ "services/misc/bazarr.nix" ];

  options.services.bazarr = {
    enable = mkEnableOption "Enable bazarr";

    dataDir = mkOption {
      type = types.path;
      description = "Path to store Bazarr files in";
      default = "/var/lib/bazarr/config";
    };

    port = mkOption {
      type = types.port;
      description = "Port for Bazarr to listen on";
      default = 6767;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open ports in the firewall for the Bazarr web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      environment = { TZ = "America/New_York"; };
      volumes = [ "${cfg.dataDir}:/config" ];
      ports = [ "${toString cfg.port}:6767" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
