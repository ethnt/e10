{ config, ... }:
let
  downloadDir = "/mnt/blockbuster/tmp/sabnzbd/inter";
  completeDir = "/mnt/blockbuster/tmp/sabnzbd/dst";
in
{
  sops = {
    secrets = {
      sabnzbd_admin_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_api_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_nzb_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newsgroup_ninja_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newsgroup_ninja_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_eweka_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_eweka_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newshosting_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newshosting_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newsgroup_direct_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_newsgroup_direct_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_xsnews_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };

      sabnzbd_xsnews_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        owner = config.services.sabnzbd.user;
      };
    };
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    configFile = null;
    secretValues = {
      "@sabnzbd_admin_password@" = config.sops.secrets.sabnzbd_admin_password.path;
      "@sabnzbd_api_key@" = config.sops.secrets.sabnzbd_api_key.path;
      "@sabnzbd_nzb_key@" = config.sops.secrets.sabnzbd_nzb_key.path;
      "@sabnzbd_newsgroup_ninja_username@" = config.sops.secrets.sabnzbd_newsgroup_ninja_username.path;
      "@sabnzbd_newsgroup_ninja_password@" = config.sops.secrets.sabnzbd_newsgroup_ninja_password.path;
      "@sabnzbd_xsnews_username@" = config.sops.secrets.sabnzbd_xsnews_username.path;
      "@sabnzbd_xsnews_password@" = config.sops.secrets.sabnzbd_xsnews_password.path;
      "@sabnzbd_newshosting_username@" = config.sops.secrets.sabnzbd_newshosting_username.path;
      "@sabnzbd_newshosting_password@" = config.sops.secrets.sabnzbd_newshosting_password.path;
      "@sabnzbd_newsgroup_direct_username@" = config.sops.secrets.sabnzbd_newsgroup_direct_username.path;
      "@sabnzbd_newsgroup_direct_password@" = config.sops.secrets.sabnzbd_newsgroup_direct_password.path;
      "@sabnzbd_eweka_username@" = config.sops.secrets.sabnzbd_eweka_username.path;
      "@sabnzbd_eweka_password@" = config.sops.secrets.sabnzbd_eweka_password.path;
    };
    settings = {
      misc = {
        port = 8080;
        host = "0.0.0.0";
        username = "admin";
        password = "@sabnzbd_admin_password@";
        api_key = "@sabnzbd_api_key@";
        nzb_key = "@sabnzbd_nzb_key@";
        permissions = 777;
        download_dir = downloadDir;
        complete_dir = completeDir;
        admin_dir = "/var/lib/sabnzbd/admin/";
        log_dir = "/var/lib/sabnzbd/logs/";
        host_whitelist = "htpc,";
        inet_exposure = "api+web (auth needed)";
        cache_limit = "512M";
      };
      servers = {
        "news-us.newsgroup.ninja" = {
          name = "news-us.newsgroup.ninja";
          displayname = "news-us.newsgroup.ninja";
          host = "news-us.newsgroup.ninja";
          port = 563;
          username = "@sabnzbd_newsgroup_ninja_username@";
          password = "@sabnzbd_newsgroup_ninja_password@";
          connections = 40;
          ssl = true;
          ssl_verify = "strict";
          enable = true;
          required = false;
          expire_date = "2026-10-29";
          priority = 0;
        };
        "reader.xsnews.nl" = {
          name = "reader.xsnews.nl";
          displayname = "reader.xsnews.nl";
          host = "reader.xsnews.nl";
          username = "@sabnzbd_xsnews_username@";
          password = "@sabnzbd_xsnews_password@";
          port = 563;
          connections = 15;
          ssl = true;
          ssl_verify = "strict";
          enable = false;
          required = false;
          expire_date = "";
          priority = 0;
        };
        "news.newshosting.com" = {
          name = "news.newshosting.com";
          displayname = "news.newshosting.com";
          host = "news.newshosting.com";
          username = "@sabnzbd_newshosting_username@";
          password = "@sabnzbd_newshosting_password@";
          port = 563;
          connections = 100;
          ssl = true;
          ssl_verify = "strict";
          enable = true;
          required = false;
          expire_date = "2026-08-29";
          priority = 0;
        };
        "news.newsgroupdirect.com" = {
          name = "news.newsgroupdirect.com";
          displayname = "NewsgroupDirect";
          host = "news.newsgroupdirect.com";
          username = "@sabnzbd_newsgroup_direct_username@";
          password = "@sabnzbd_newsgroup_direct_password@";
          port = 563;
          connections = 8;
          ssl = true;
          ssl_verify = "strict";
          enable = true;
          required = false;
          expire_date = "";
          quota = "4000G";
          priority = 1;
        };
        "news.eweka.nl" = {
          name = "news.eweka.nl";
          displayname = "news.eweka.nl";
          host = "news.eweka.nl";
          username = "@sabnzbd_eweka_username@";
          password = "@sabnzbd_eweka_password@";
          port = 563;
          connections = 50;
          ssl = true;
          ssl_verify = "strict";
          enable = true;
          required = false;
          expire_date = "2027-05-13";
          priority = 0;
        };
      };
      categories = {
        "*" = {
          name = "*";
          order = 0;
          pp = 3;
          priority = 0;
        };
        movies = {
          name = "movies";
          order = 0;
          priority = -100;
        };
        tv = {
          name = "tv";
          order = 0;
          priority = -100;
        };
        audio = {
          name = "audio";
          order = 0;
          priority = -100;
        };
        software = {
          name = "software";
          order = 0;
          priority = -100;
        };
        prowlarr = {
          name = "prowlarr";
          order = 1;
          priority = -100;
        };
        books = {
          name = "books";
          order = 2;
          priority = -100;
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d '${downloadDir}' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    "d '${completeDir}' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
  ];

  systemd.services.sabnzbd.unitConfig.RequiresMountsFor = [ "/mnt/blockbuster" ];
}
