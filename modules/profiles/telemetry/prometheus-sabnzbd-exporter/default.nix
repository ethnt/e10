{ config, ... }: {
  sops.secrets.prometheus_sabnzbd_exporter_sabnzbd_api_key = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.exportarr-sabnzbd = {
    enable = true;
    url = "https://sabnzbd.e10.camp";
    openFirewall = true;
    apiKeyFile =
      config.sops.secrets.prometheus_sabnzbd_exporter_sabnzbd_api_key.path;
    port = 9712;
  };
}
