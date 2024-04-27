{ config, ... }: {
  sops.secrets.sonarr_api_key = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.exportarr-sonarr = {
    enable = true;
    url = "https://sonarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.sonarr_api_key.path;
    port = 9708;
  };
}
