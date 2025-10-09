{ config, profiles, ... }: {
  imports = [ profiles.shared-secrets.bazarr.default ];

  services.prometheus.exporters.exportarr-bazarr = {
    enable = true;
    url = "https://bazarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.bazarr_api_key.path;
    port = 9710;
  };
}
