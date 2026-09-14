{ config, profiles, ... }: {
  imports = [ profiles.secrets.prowlarr.default ] ++ [ ./postgresql.nix ];

  sops = {
    templates."prowlarr/environment_file" = {
      content = ''
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder.prowlarr_api_key}
      '';
      mode = "0750";
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
    environmentFiles = [ config.sops.templates."prowlarr/environment_file".path ];
    settings = {
      postgres = {
        host = "localhost";
        port = config.services.postgresql.settings.port;
        maindb = "prowlarr";
        user = "prowlarr";
        password = "";
      };
      log = {
        level = "info";
        dbenabled = false;
      };
      auth = {
        method = "Forms";
        required = "Enabled";
      };
      update = {
        automatically = false;
        mechanism = "external";
      };
    };
  };
}
