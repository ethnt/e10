{ config, ... }: {
  sops.secrets.prowlarr_api_key = { sopsFile = ./secrets.json; };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.prometheus.exporters.exportarr-prowlarr = {
    enable = true;
    url = "https://prowlarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.prowlarr_api_key.path;
    environment = { PROWLARR__BACKFILL = "true"; };
    port = 9711;
  };
}
