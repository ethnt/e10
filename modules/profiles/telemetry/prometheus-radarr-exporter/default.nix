{ config, ... }: {
  sops.secrets.radarr_api_key = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.exportarr-radarr = {
    enable = true;
    url = "https://radarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.radarr_api_key.path;
    port = 9709;
  };
}
