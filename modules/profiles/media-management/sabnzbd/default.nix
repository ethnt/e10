{ flake, config, ... }: {
  sops = {
    secrets = {
      sabnzbd_admin_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_api_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_nzb_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_ninja_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_ninja_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_eweka_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_eweka_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newshosting_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newshosting_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_direct_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_newsgroup_direct_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_supernews_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_supernews_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_xsnews_username = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      sabnzbd_xsnews_password = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };
    };

    templates."sabnzbd/secrets.ini" = {
      content = flake.lib.generators.toINI {
        globalSection = { };
        sections = {
          misc = {
            password = config.sops.placeholder.sabnzbd_admin_password;
            api_key = config.sops.placeholder.sabnzbd_api_key;
            nzb_key = config.sops.placeholder.sabnzbd_nzb_key;
          };
          servers = {
            "news-us.newsgroup.ninja" = {
              username =
                config.sops.placeholder.sabnzbd_newsgroup_ninja_username;
              password =
                config.sops.placeholder.sabnzbd_newsgroup_ninja_password;
            };
            "news.supernews.com" = {
              username = config.sops.placeholder.sabnzbd_supernews_username;
              password = config.sops.placeholder.sabnzbd_supernews_password;
            };
            "reader.xsnews.nl" = {
              username = config.sops.placeholder.sabnzbd_xsnews_username;
              password = config.sops.placeholder.sabnzbd_xsnews_password;
            };
            "news.newshosting.com" = {
              username = config.sops.placeholder.sabnzbd_newshosting_username;
              password = config.sops.placeholder.sabnzbd_newshosting_password;
            };
            "news.newsgroupdirect.com" = {
              username =
                config.sops.placeholder.sabnzbd_newsgroup_direct_username;
              password =
                config.sops.placeholder.sabnzbd_newsgroup_direct_password;
            };
            "news.eweka.nl" = {
              username = config.sops.placeholder.sabnzbd_eweka_username;
              password = config.sops.placeholder.sabnzbd_eweka_password;
            };
          };
        };
      };
      owner = config.services.sabnzbd.user;
    };
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    configFile = null;
    secretFiles = [ config.sops.templates."sabnzbd/secrets.ini".path ];
    settings = {
      misc = {
        port = 8080;
        host = "0.0.0.0";
        username = "admin";
        permissions = 777;
        download_dir = "/data/local/tmp/sabnzbd/inter";
        complete_dir = "/data/local/tmp/sabnzbd/dst";
        admin_dir = "/var/lib/sabnzbd/admin/";
        log_dir = "/var/lib/sabnzbd/logs/";
        host_whitelist = "htpc,";
        inet_exposure = "api+web (auth needed)";
      };
      servers = {
        "news-us.newsgroup.ninja" = {
          name = "news-us.newsgroup.ninja";
          displayname = "news-us.newsgroup.ninja";
          host = "news-us.newsgroup.ninja";
          port = 563;
          timeout = 60;
          connections = 40;
          ssl = true;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "2026-10-29";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
        };
        "news.supernews.com" = {
          name = "news.supernews.com";
          displayname = "news.supernews.com";
          host = "news.supernews.com";
          port = 119;
          timeout = 60;
          connections = 15;
          ssl = false;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = false;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
        };
        "reader.xsnews.nl" = {
          name = "reader.xsnews.nl";
          displayname = "reader.xsnews.nl";
          host = "reader.xsnews.nl";
          port = 563;
          timeout = 60;
          connections = 15;
          ssl = true;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = false;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
        };
        "news.newshosting.com" = {
          name = "news.newshosting.com";
          displayname = "news.newshosting.com";
          host = "news.newshosting.com";
          port = 563;
          timeout = 60;
          connections = 100;
          ssl = true;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "2026-08-29";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
        };
        "news.newsgroupdirect.com" = {
          name = "news.newsgroupdirect.com";
          displayname = "NewsgroupDirect";
          host = "news.newsgroupdirect.com";
          port = 563;
          timeout = 60;
          connections = 8;
          ssl = true;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "";
          quota = "4000G";
          usage_at_start = 0;
          priority = 1;
          notes = "";
        };
        "news.eweka.nl" = {
          name = "news.eweka.nl";
          displayname = "news.eweka.nl";
          host = "news.eweka.nl";
          port = 563;
          timeout = 60;
          connections = 50;
          ssl = true;
          ssl_verify = "strict";
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "2027-05-13";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
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
    "d '/data/local/tmp/sabnzbd/inter' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    "d '/data/local/tmp/sabnzbd/dst' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
  ];

  services.prometheus.exporters.exportarr-sabnzbd = {
    enable = true;
    url = "https://sabnzbd.e10.camp";
    openFirewall = true;
    apiKeyFile = config.sops.secrets.sabnzbd_api_key.path;
    port = 9712;
  };
}
