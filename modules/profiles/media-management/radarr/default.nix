{
  config,
  profiles,
  ...
}:
{
  imports = [ profiles.secrets.radarr.default ] ++ [ ./postgresql.nix ];

  sops = {
    templates."radarr/environment_file" = {
      content = ''
        RADARR__AUTH__APIKEY=${config.sops.placeholder.radarr_api_key}
      '';
      owner = config.services.radarr.user;
      inherit (config.services.radarr) group;
      mode = "0660";
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    environmentFiles = [ config.sops.templates."radarr/environment_file".path ];
    settings = {
      app = {
        instancename = "Radarr";
        launchbrowser = false;
      };
      server = {
        bindaddress = "*";
        port = 9898;
        enablessl = false;
      };
      postgres = {
        host = "localhost";
        port = config.services.postgresql.settings.port;
        maindb = "radarr";
        user = "radarr";
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
