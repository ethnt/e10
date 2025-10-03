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
      image = "nvcr.io/nvidia/k8s/dcgm-exporter:latest";
      ports = [ "${toString cfg.port}:9400" ];
      environment = {
        NVIDIA_DRIVER_CAPABILITIES = "compute,video,utility";
        NVIDIA_VISIBLE_DEVICES = "all";
      };
      extraOptions = [ "--cap-add=SYS_ADMIN" "--device=nvidia.com/gpu=all" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
