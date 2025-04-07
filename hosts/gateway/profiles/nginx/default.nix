{ config, profiles, lib, hosts, ... }: {
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
    genericProxyConfiguration = ''
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    '';
    autheliaProxyHeaders = ''
      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header Content-Length "";
      # proxy_set_header Connection "upgrade";
    '';
    autheliaProxyConfiguration = ''
      proxy_pass_request_body off;
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
      proxy_redirect http:// $scheme://;
      # proxy_http_version 1.1;
      proxy_cache_bypass $cookie_session;
      proxy_no_cache $cookie_session;
      proxy_buffers 4 32k;
      client_body_buffer_size 128k;
    '';
    autheliaAdvancedProxyConfiguration = ''
      send_timeout 5m;
      proxy_read_timeout 240;
      proxy_send_timeout 240;
      proxy_connect_timeout 240;
    '';
    autheliaInternalLocationConfig = ''
      internal;
      proxy_pass http://localhost:9091/api/authz/auth-request;

      ${autheliaProxyHeaders}
      ${autheliaProxyConfiguration}
      ${autheliaAdvancedProxyConfiguration}
    '';
    autheliaLocationConfig = ''
      ${autheliaProxyHeaders}
      ${autheliaProxyConfiguration}
      ${autheliaAdvancedProxyConfiguration}

      ## Send a subrequest to Authelia to verify if the user is authenticated and has permission to access the resource.
      auth_request /internal/authelia/authz;

      ## Save the upstream metadata response headers from Authelia to variables.
      auth_request_set $user $upstream_http_remote_user;
      auth_request_set $groups $upstream_http_remote_groups;
      auth_request_set $name $upstream_http_remote_name;
      auth_request_set $email $upstream_http_remote_email;

      ## Inject the metadata response headers from the variables into the request made to the backend.
      proxy_set_header Remote-User $user;
      proxy_set_header Remote-Groups $groups;
      proxy_set_header Remote-Email $email;
      proxy_set_header Remote-Name $name;

      auth_request_set $redirection_url $upstream_http_location;

      error_page 401 =302 $redirection_url;
    '';
    mkVirtualHost = { host, port, http2 ? true, protected ? false
      , extraConfig ? " ", extraHostConfiguration ? { }
      , extraRootLocationConfig ? "" }:
      let
        resolvedHost = if host == hosts.gateway then
          "localhost"
        else
          host.config.networking.hostName;
      in {
        inherit http2 extraConfig;

        forceSSL = true;
        enableACME = true;

        locations = {
          "/internal/authelia/authz" = lib.mkIf protected {
            extraConfig = autheliaInternalLocationConfig;
          };

          "/" = {
            proxyPass = "http://${resolvedHost}:${toString port}";
            # proxyWebsockets = true;
            extraConfig = ''
              ${genericProxyConfiguration}

              ${extraRootLocationConfig}
              ${lib.optionalString protected autheliaLocationConfig}
            '';
          };
        };
      } // extraHostConfiguration;

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
      protected = true;
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

    "glance.e10.camp" = mkVirtualHost {
      host = hosts.matrix;
      inherit (hosts.matrix.config.services.glance.settings.server) port;
      # protected = true;
    };

    "ldap.e10.camp" = mkVirtualHost {
      host = hosts.gateway;
      port = hosts.controller.config.services.lldap.settings.http_port;
    };

    "auth.e10.camp" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:9091";
          extraConfig = ''
            ## Headers
            proxy_set_header Host $host;
            proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-URI $request_uri;
            proxy_set_header X-Forwarded-Ssl on;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Real-IP $remote_addr;

            ## Basic Proxy Configuration
            client_body_buffer_size 128k;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
            proxy_redirect  http://  $scheme://;
            # proxy_http_version 1.1;
            proxy_cache_bypass $cookie_session;
            proxy_no_cache $cookie_session;
            proxy_buffers 64 256k;

            ## Trusted Proxies Configuration
            ## Please read the following documentation before configuring this:
            ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
            # set_real_ip_from 10.0.0.0/8;
            # set_real_ip_from 172.16.0.0/12;
            # set_real_ip_from 192.168.0.0/16;
            # set_real_ip_from fc00::/7;
            real_ip_header X-Forwarded-For;
            real_ip_recursive on;

            ## Advanced Proxy Configuration
            send_timeout 5m;
            proxy_read_timeout 360;
            proxy_send_timeout 360;
            proxy_connect_timeout 360;
          '';
        };

        "/api/verify".proxyPass = "http://localhost:9091";
        "/api/authz/".proxyPass = "http://localhost:9091";
      };
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
        # proxy_set_header Connection "upgrade";
        # proxy_http_version 1.1;
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
