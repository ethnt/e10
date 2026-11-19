{ config, ... }: {
  sops.secrets = {
    dawarich_secret_key_base = {
      sopsFile = ./secrets.json;
      owner = config.services.dawarich.user;
      inherit (config.services.dawarich) group;
    };

    dawarich_smtp_password = {
      sopsFile = ./secrets.json;
      owner = config.services.dawarich.user;
      inherit (config.services.dawarich) group;
    };
  };

  services.dawarich = {
    enable = true;
    localDomain = "dawarich.e10.camp";
    secretKeyBaseFile = config.sops.secrets.dawarich_secret_key_base.path;
    configureNginx = false;
    smtp = {
      user = "e10_smtp";
      host = "mail.smtp2go.com";
      port = 2525;
      passwordFile = config.sops.secrets.dawarich_smtp_password.path;
      fromAddress = "admin@e10.camp";
    };
  };

  services.caddy.virtualHosts = {
    "http://dawarich.e10.camp:9010" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.dawarich.webPort}
      '';
    };
  };

  services.postgresqlBackup.databases = [ config.services.dawarich.database.name ];
}
