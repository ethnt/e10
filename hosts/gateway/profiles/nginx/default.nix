{ config, profiles, hosts, ... }: {
  imports = [ profiles.web-servers.nginx ];

  sops.secrets = {
    nginx_fileflows_basic_auth_file = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.nginx.user;
      inherit (config.services.nginx) group;
    };

    lego_route53_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.nginx.virtualHosts = let
    mkVirtualHost = { host, port, http2 ? true, basicAuthFile ? null
      , extraConfig ? " ", extraSettings ? { }, extraRootLocationConfig ? "" }:
      {
        inherit http2 extraConfig;

        forceSSL = true;
        enableACME = true;

        locations."/" = {
          inherit basicAuthFile;

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

    "bazarr.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      port = hosts.htpc.config.services.bazarr.listenPort;
    };

    "sabnzbd.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.sabnzbd) port;
      extraConfig = ''
        client_max_body_size 256M;
      '';
    };

    "overseerr.e10.camp" = mkRedirect { destination = "requests.e10.video"; };

    "requests.e10.video" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.overseerr) port;
    };

    "tautulli.e10.camp" = mkRedirect { destination = "tautulli.e10.video"; };

    "tautulli.e10.video" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.tautulli) port;
    };

    "cache.builder.e10.camp" = mkVirtualHost {
      host = hosts.builder;
      inherit (hosts.builder.config.services.nix-serve) port;
    };

    "fileflows.e10.camp" = mkVirtualHost {
      host = hosts.htpc;
      inherit (hosts.htpc.config.services.fileflows-server) port;
      basicAuthFile = config.sops.secrets.nginx_fileflows_basic_auth_file.path;
    };

    "paperless.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      inherit (hosts.matrix.config.services.paperless) port;
      extraConfig = ''
        client_max_body_size 100M;
      '';
      extraRootLocationConfig = ''
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;
        add_header Referrer-Policy "strict-origin-when-cross-origin";
      '';
    };

    "immich.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      inherit (hosts.matrix.config.services.immich) port;
      extraConfig = ''
        client_max_body_size 50000M;
      '';
    };

    "web.garage.e10.camp" = {
      forceSSL = true;
      useACMEHost = "web.garage.e10.camp";
      serverAliases = [ "*.web.garage.e10.camp" ];

      locations."/" = {
        proxyPass =
          "http://${hosts.omnibus.config.networking.hostName}:${toString 3900}";
      };
    };

    "s3.garage.e10.camp" = {
      forceSSL = true;
      useACMEHost = "s3.garage.e10.camp";
      serverAliases = [ "*.s3.garage.e10.camp" ];

      locations."/" = {
        proxyPass =
          "http://${hosts.omnibus.config.networking.hostName}:${toString 3900}";
        extraConfig = ''
          proxy_max_temp_file_size 0;
          client_max_body_size 5G;
        '';
      };
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

    "change-detection.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      inherit (hosts.matrix.config.services.changedetection-io) port;
    };

    "cache.e10.camp" = mkVirtualHost {
      host = hosts.omnibus;
      port = 8080;
      extraConfig = ''
        client_max_body_size 10G;
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

  security.acme.certs = {
    "s3.garage.e10.camp" = {
      domain = "s3.garage.e10.camp";
      extraDomainNames = [ "*.s3.garage.e10.camp" ];
      dnsProvider = "route53";
      credentialsFile = config.sops.secrets.lego_route53_credentials.path;

      group = "nginx";
    };

    "web.garage.e10.camp" = {
      domain = "web.garage.e10.camp";
      extraDomainNames = [ "*.web.garage.e10.camp" ];
      dnsProvider = "route53";
      credentialsFile = config.sops.secrets.lego_route53_credentials.path;

      group = "nginx";
    };

  };
}
