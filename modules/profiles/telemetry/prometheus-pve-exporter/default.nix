{ config, ... }: {
  sops.secrets.prometheus_pve_exporter_config = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.pve = {
    enable = true;
    configFile = config.sops.secrets.prometheus_pve_exporter_config.path;
    openFirewall = true;
  };
}
