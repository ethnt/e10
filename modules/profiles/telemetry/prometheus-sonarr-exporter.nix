{ config, ... }: {
  services.prometheus.exporters.exportarr-sonarr = {
    enable = true;
    url = "https://sonarr.e10.camp";
    apiKeyFile = config.sops.secrets.sonarr_api_key.path;
    port = 9708;
    openFirewall = true;
  };
}
