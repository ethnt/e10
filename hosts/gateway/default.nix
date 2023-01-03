{ config, lib, pkgs, suites, profiles, hosts, modulesPath, ... }: {
  imports = with suites;
    base ++ network ++ aws ++ web ++ observability ++ (with profiles; [
      networking.nebula.lighthouse
      networking.blocky.common
      databases.postgresql.common
      databases.postgresql.blocky
    ]);

  e10 = {
    privateAddress = config.services.nebula.networks.e10.address;
    publicAddress = "3.136.251.131";
    domain = "gateway.e10.network";
    deployable = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      nebula_host_key = { };
      nebula_host_cert = { };
    };
  };

  services.nebula.networks.e10 = {
    address = "10.10.0.1";
    key = config.sops.secrets.nebula_host_key.path;
    cert = config.sops.secrets.nebula_host_cert.path;
  };

  services.nginx.virtualHosts = {
    "e10.land" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.matrix.config.e10.privateAddress}:8090";
      };
    };

    "dns.e10.network" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.matrix.config.e10.privateAddress}:${
            toString hosts.matrix.config.services.blocky.settings.httpPort
          }";
      };
    };

    "e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        send_timeout 100m;
        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $server_addr;
        proxy_set_header Referer $server_addr;
        proxy_set_header Origin $server_addr;
        gzip on;
        gzip_vary on;
        gzip_min_length 1000;
        gzip_proxied any;
        gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
        gzip_disable "MSIE [1-6]\.";
        client_max_body_size 100M;
        proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
        proxy_set_header X-Plex-Device $http_x_plex_device;
        proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
        proxy_set_header X-Plex-Platform $http_x_plex_platform;
        proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
        proxy_set_header X-Plex-Product $http_x_plex_product;
        proxy_set_header X-Plex-Token $http_x_plex_token;
        proxy_set_header X-Plex-Version $http_x_plex_version;
        proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
        proxy_set_header X-Plex-Provides $http_x_plex_provides;
        proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
        proxy_set_header X-Plex-Model $http_x_plex_model;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
        proxy_redirect off;
        proxy_buffering off;
      '';

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.plex.port
          }";
      };
    };

    "prowlarr.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.prowlarr.port
          }";
        proxyWebsockets = true;
      };
    };

    "sonarr.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.sonarr.port
          }";
        proxyWebsockets = true;
      };
    };

    "radarr.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.radarr.port
          }";
        proxyWebsockets = true;
      };
    };

    "sabnzbd.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        client_max_body_size 100M;
      '';

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.sabnzbd.port
          }";
        proxyWebsockets = true;
      };
    };

    "bazarr.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.bazarr.listenPort
          }";
        proxyWebsockets = true;
      };
    };

    "tautulli.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.tautulli.port
          }";
        proxyWebsockets = true;
      };
    };

    # "tdarr.e10.video" = {
    #   http2 = true;

    #   forceSSL = true;
    #   enableACME = true;

    #   locations."/" = {
    #     proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
    #         toString hosts.htpc.config.services.tdarr.webUIPort
    #       }";
    #     proxyWebsockets = true;
    #   };
    # };

    "overseerr.e10.video" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.htpc.config.e10.privateAddress}:${
            toString hosts.htpc.config.services.overseerr.port
          }";
        proxyWebsockets = true;
      };
    };

    "feeds.e10.network" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${hosts.matrix.config.e10.privateAddress}:${
            toString hosts.matrix.config.services.miniflux.config.PORT
          }";
        proxyWebsockets = true;
      };
    };

    "pve.e10.network" = {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass =
          "http://${hosts.matrix.config.e10.privateAddress}:${toString 9010}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };

  networking.hostName = "gateway";
}
