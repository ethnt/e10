{ config, lib, ... }:

with lib;

let cfg = config.services.prometheus.exporters.dcgm-exporter;

in {
  options.services.prometheus.exporters.dcgm-exporter = {
    enable = mkEnableOption "Enable dcgm exporter";

    port = mkOption {
      type = types.port;
      default = 9400;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.prometheus-dcgm-exporter = {
      autoStart = true;
      image = "nvcr.io/nvidia/k8s/dcgm-exporter:3.1.8-3.1.5-ubuntu20.04";
      ports = [ "${toString cfg.port}:9400" ];
      extraOptions =
        [ "--network" "host" "--cap-add" "SYS_ADMIN" "--gpus" "all" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
