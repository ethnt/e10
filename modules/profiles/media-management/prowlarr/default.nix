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

  provides.prowlarr = {
    name = "Prowlarr";
    http = {
      enable = true;
      inherit (config.services.prowlarr.settings.server) port;
      domain = "prowlarr.e10.camp";
    };
  };
}
