{
  services.prometheus-exporters-intel-gpu = {
    enable = true;
    openFirewall = true;
  };
  # virtualisation.oci-containers.containers.intel-gpu-exporter = {
  #   image = "restreamio/intel-prometheus";
  #   ports = [ "9571:8080" ];
  #   volumes = [ "/dev/dri:/dev/dri" ];
  #   extraOptions = [ "--privileged" ];
  # };

  # networking.firewall.allowedTCPPorts = [ 9571 ];
}
