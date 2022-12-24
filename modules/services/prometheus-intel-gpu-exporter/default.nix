{ config, lib, ... }:

with lib;

let cfg = config.services.prometheus-exporters-intel-gpu;
in {
  options.services.prometheus-exporters-intel-gpu = {
    enable = mkEnableOption "Enable Intel GPU exporter for Prometheus";

    port = mkOption {
      type = types.port;
      description = "Which port to run the exporter on";
      default = 9571;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open ports in the firewall for the Intel GPU exporter";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.intel-gpu-exporter = {
      image = "restreamio/intel-prometheus";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [ "/dev/dri:/dev/dri" ];
      extraOptions = [ "--privileged" ];
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
