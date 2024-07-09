{ config, suites, hosts, ... }: {
  imports = with suites; core ++ web ++ aws;

  services.nginx.virtualHosts = let
    mkVirtualHost = { host, port, http2 ? true, extraConfig ? " "
      , extraSettings ? { }, extraRootLocationConfig ? "" }:
      {
        inherit http2 extraConfig;

        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass =
            "http://${host.config.networking.hostName}:${toString port}";
          proxyWebsockets = true;
          extraConfig = extraRootLocationConfig;
        };
      } // extraSettings;

    mkRedirect = { destination, status ? 301 }: {
      http2 = true;

      forceSSL = true;
      enableACME = true;

      globalRedirect = destination;
      redirectCode = status;
    };
  in {
    "e10.land" = mkVirtualHost {
      host = hosts.matrix;
      port = 8090;
    };

    "feeds.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      port = hosts.matrix.config.services.miniflux.config.PORT;
    };

    "blocky.e10.camp" = mkVirtualHost {
      host = hosts.controller;
      port = hosts.controller.config.services.blocky.settings.ports.http;
    };

    "prowlarr.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.prowlarr) port;
    };

    "radarr.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.radarr) port;
    };

    "sonarr.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.sonarr) port;
    };

    "sabnzbd.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.sabnzbd) port;
      extraConfig = ''
        client_max_body_size 256M;
      '';
    };

    # "bazarr.e10.camp" = mkVirtualHost {
    #   host = hosts.htpc;
    #   port = hosts.htpc.config.services.bazarr.listenPort;
    # };

    "overseerr.e10.camp" = mkRedirect { destination = "requests.e10.video"; };

    "requests.e10.video" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.overseerr) port;
    };

    "tautulli.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.tautulli) port;
    };

    "cache.builder.e10.camp" = mkVirtualHost {
      host = hosts.builder;
      inherit (hosts.builder.config.services.nix-serve) port;
    };

    "netbox.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      port = 8002;
      extraRootLocationConfig = ''
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    "e10.video" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.plex) port;
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
    };
  };

  system.stateVersion = "24.05";
}
