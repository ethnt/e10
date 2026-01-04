{ config, lib, ... }:

with lib;

let cfg = config.services.bichon;
in {
  options.services.bichon = {
    enable = mkEnableOption "Enable Bichon";

    port = mkOption {
      type = types.port;
      default = 15630;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/bichon";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-bichon" = {
      ${cfg.dataDir} = {
        "d" = {
          user = config.virtualisation.oci-containers.backend;
          group = config.virtualisation.oci-containers.backend;
          mode = "0700";
        };
      };
    };

    virtualisation.oci-containers.containers.bichon = {
      image = "rustmailer/bichon:latest";
      ports = [ "${toString cfg.port}:15630" ];
      volumes = [ "${cfg.dataDir}:/data" ];
      environment = { BICHON_ROOT_DIR = "/data"; };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall 15630;
  };
}
