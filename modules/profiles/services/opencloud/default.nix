{ config, ... }: {
  services.opencloud = {
    enable = true;
    url = "https://opencloud.e10.camp";
    environment = {
      OC_SECURE = "true";
      PROXY_TLS = "false";
      PROXY_INSECURE_BACKENDS = "true";
      OC_EXCLUDE_RUN_SERVICES = "idp";
      OC_OIDC_ISSUER = "https://auth.e10.camp";
      WEB_UI_CONFIG_FILE = "/var/lib/opencloud/config.json";
    };
    settings = {
      log.level = "debug";
      web.http.addr = "0.0.0.0:9561";
      web.log.level = "debug";
      # web.web.config.oidc.client_id = "opencloud";
      # web.web.config.oidc.scope = "openid profile email groups";
    };
    port = 9560;
  };

  environment.etc."opencloud/config.json" = {
    text = builtins.toJSON {
      server = "https://opencloud.e10.camp";
      theme = "https://opencloud.e10.camp/themes/owncloud/theme.json";
      version = "0.1.0";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.opencloud.port ];
}
