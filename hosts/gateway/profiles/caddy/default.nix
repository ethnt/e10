{ config, hosts, ... }: {
  sops.secrets = {
    e10_camp_lego_route53_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    e10_video_lego_route53_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    e10_land_lego_route53_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.caddy-proxy = {
    enable = true;
    proxies = {
      "e10.land" = {
        host = hosts.matrix;
        port = 8090;
        extraConfig = ''
          encode gzip zstd

          rate_limit {
            zone ip_limiter {
              key {http.request.remote.host}
              window 2s
              events 6
            }
          }
        '';
      };

      "feeds.e10.camp" = {
        host = hosts.matrix;
        port = hosts.matrix.config.services.miniflux.config.PORT;
      };

      "prowlarr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.prowlarr) port;
      };

      "radarr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.radarr) port;
      };

      "sonarr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.sonarr) port;
      };

      "bazarr.e10.camp" = {
        host = hosts.htpc;
        port = hosts.htpc.config.services.bazarr.listenPort;
      };

      "sabnzbd.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.sabnzbd) port;
        # extraConfig = ''
        #   client_max_body_size 256M;
        # '';
      };

      "requests.e10.video" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.overseerr) port;
        acme.environmentFile =
          config.sops.secrets.e10_video_lego_route53_credentials.path;
      };

      "tautulli.e10.video" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.tautulli) port;
        acme.environmentFile =
          config.sops.secrets.e10_video_lego_route53_credentials.path;
      };

      "cache.builder.e10.camp" = {
        host = hosts.builder;
        inherit (hosts.builder.config.services.nix-serve) port;
        extraConfig = ''
          request_body {
            max_size 2GiB
          }
        '';
      };

      "fileflows.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.fileflows-server) port;
        protected = true;
      };

      "paperless.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.paperless) port;
        extraConfig = ''
          request_body {
            max_size 100MB
          }
        '';
      };

      "immich.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.immich) port;
        extraConfig = ''
          request_body {
            max_size 50GiB
          }
        '';
      };

      "netbox.e10.camp" = {
        host = hosts.matrix;
        port = 8002;
      };

      "change-detection.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.changedetection-io) port;
      };

      "cache.e10.camp" = {
        host = hosts.omnibus;
        port = 8080;
        extraConfig = ''
          encode gzip zstd

          request_body {
            max_size 10GB
          }
        '';
      };

      "glance.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.glance.settings.server) port;
        protected = true;
      };

      "ldap.e10.camp" = {
        host = hosts.gateway;
        port = hosts.controller.config.services.lldap.settings.http_port;
      };

      "auth.e10.camp" = {
        host = hosts.gateway;
        port = 9091;
        # TODO: This (somewhat) fixes issues with PWAs grabbing manifest.json files
        # https://github.com/authelia/authelia/discussions/4629
        extraConfig = ''
          header Access-Control-Allow-Origin "*"
        '';
      };

      "e10.video" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.plex) port;
        extraConfig = ''
          encode gzip zstd

          header {
            Strict-Transport-Security max-age=31536000;
            X-Content-Type-Options nosniff
            X-Frame-Options DENY
            Referrer-Policy no-referrer-when-downgrade
            X-XSS-Protection 1
          }

          request_body {
            max_size 100MB
          }
        '';
      };

      "web.garage.e10.camp" = {
        host = hosts.omnibus;
        port = 3902;
        acme = {
          generate = true;
          provider = "route53";
          environmentFile =
            config.sops.secrets.e10_camp_lego_route53_credentials.path;
        };
      };

      "s3.garage.e10.camp" = {
        host = hosts.omnibus;
        port = 3900;
        acme = {
          generate = true;
          provider = "route53";
          environmentFile =
            config.sops.secrets.e10_camp_lego_route53_credentials.path;
        };
        extraConfig = ''
          encode gzip zstd

          request_body {
            max_size 1GiB
          }
        '';
      };

      "admin.garage.e10.camp" = {
        host = hosts.omnibus;
        port = 3903;
        acme = {
          generate = true;
          provider = "route53";
          environmentFile =
            config.sops.secrets.e10_camp_lego_route53_credentials.path;
        };
      };
    };
  };
}
