{ config, lib, ... }:

with lib;

let cfg = config.services.prometheus.exporters.plex-media-server;
in {
  options.services.prometheus.exporters.plex-media-server = {
    enable = mkEnableOption "Enable Plex Media Server exporter";

    port = mkOption {
      type = types.port;
      default = 9594;
      description = "Port to expose for this exporter";
    };

    url = mkOption {
      type = types.str;
      description = "URL of the Plex server to monitor";
    };

    secretsFile = mkOption {
      type = types.path;
      description = "Path to a secrets file containing the Plex token";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to open the firewall for the exporter";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.prometheus-plex-media-server-exporter =
      {
        image = "ghcr.io/axsuul/plex-media-server-exporter";
        environment.PLEX_ADDR = cfg.url;
        environmentFiles = [ cfg.secretsFile ];
        ports = [ "${toString cfg.port}:9594" ];
      };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
