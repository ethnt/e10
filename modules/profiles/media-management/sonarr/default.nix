{ flake, config, ... }: {
  imports = [ ./postgresql.nix ];

  sops = {
    secrets.sonarr_api_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    templates."sonarr-config.xml" = {
      content = flake.lib.generators.toXML {
        rootName = "Config";
        xmlns = { };
      } {
        ApiKey = "${config.sops.placeholder.sonarr_api_key}";
        AuthenticationMethod = "Forms";
        AuthenticationRequired = "Enabled";
        BindAddress = "*";
        Branch = "main";
        EnableSsl = false;
        InstanceName = "Sonarr";
        LaunchBrowser = true;
        LogLevel = "info";
        Port = config.services.sonarr.port;
        PostgresHost = "localhost";
        PostgresLogDb = "sonarr_logs";
        PostgresMainDb = "sonarr";
        PostgresPassword = "";
        PostgresPort = config.services.postgresql.settings.port;
        PostgresUser = "sonarr";
        SslCertPassword = null;
        SslCertPath = null;
        SslPort = 9898;
        UpdateMechanism = "builtin";
        UrlBase = null;
      };

      path = "${config.services.sonarr.dataDir}/config.xml";
      owner = config.services.sonarr.user;
      inherit (config.services.sonarr) group;
      mode = "0660";
    };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.prometheus.exporters.exportarr-sonarr = {
    enable = true;
    url = "https://sonarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.sonarr_api_key.path;
    port = 9708;
  };
}
