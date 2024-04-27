{ config, ... }: {
  sops.secrets.bazarr_api_key = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.exportarr-bazarr = {
    enable = true;
    url = "https://bazarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.bazarr_api_key.path;
    port = 9710;
  };
}
