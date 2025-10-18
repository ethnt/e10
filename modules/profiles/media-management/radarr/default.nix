{ flake, config, ... }: {
  imports = [ ./postgresql.nix ];

  sops = {
    secrets.radarr_api_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    templates."radarr-config.xml" = {
      content = flake.lib.generators.toXML {
        rootName = "Config";
        xmlns = { };
      } {
        ApiKey = "${config.sops.placeholder.radarr_api_key}";
        AuthenticationMethod = "Forms";
        AuthenticationRequired = "Enabled";
        BindAddress = "*";
        Branch = "master";
        EnableSsl = false;
        InstanceName = "Radarr";
        LaunchBrowser = false;
        LogLevel = "info";
        Port = config.services.radarr.port;
        PostgresHost = "localhost";
        PostgresLogDb = "radarr_logs";
        PostgresMainDb = "radarr";
        PostgresPassword = "";
        PostgresPort = config.services.postgresql.settings.port;
        PostgresUser = "radarr";
        SslCertPassword = null;
        SslCertPath = null;
        SslPort = 9898;
        UrlBase = null;
      };
      path = "${config.services.radarr.dataDir}/config.xml";
      owner = config.services.radarr.user;
      inherit (config.services.radarr) group;
      mode = "0660";
      restartUnits = [ "radarr.service" ];
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.radarr = {
    wants = [ "sops-nix.service" ];
    after = [ "sops-nix.service" ];
  };

  services.prometheus.exporters.exportarr-radarr = {
    enable = true;
    url = "https://radarr.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.radarr_api_key.path;
    port = 9709;
  };
}
