{
  config,
  profiles,
  ...
}:
{
  imports = [ profiles.secrets.sonarr.default ] ++ [ ./postgresql.nix ];

  sops = {
    templates."sonarr/environment_file" = {
      content = ''
        SONARR__AUTH__APIKEY=${config.sops.placeholder.sonarr_api_key}
      '';
      owner = config.services.sonarr.user;
      inherit (config.services.sonarr) group;
      mode = "0660";
    };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    environmentFiles = [ config.sops.templates."sonarr/environment_file".path ];
    settings = {
      app = {
        instancename = "Sonarr";
        launchbrowser = false;
      };
      server = {
        bindaddress = "*";
        port = 8989;
        enablessl = false;
      };
      postgres = {
        host = "localhost";
        port = config.services.postgresql.settings.port;
        maindb = "sonarr";
        logdb = "sonarr_logs";
        user = "sonarr";
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
