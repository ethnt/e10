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

  services.caddy = {
    virtualHosts = {
      "e10.camp" = {
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-e10.camp.log {
            roll_size 1GiB
            roll_keep 0
            mode 777
          }
        '';
        extraConfig = ''
          @webfinger {
            path /.well-known/webfinger
            method GET HEAD
            query rel=http://openid.net/specs/connect/1.0/issuer
          }

          handle @webfinger {
            templates {
              mime application/jrd+json
            }

            header {
              Content-Type application/jrd+json
              Access-Control-Allow-Origin *
              X-Robots-Tag noindex
            }

            respond <<JSON
            {
              "subject": "{{ placeholder "http.request.uri.query.resource" }}",
              "links": [
                {
                  "rel": "http://openid.net/specs/connect/1.0/issuer",
                  "href": "https://auth.e10.camp"
                }
              ]
            }
            JSON 200
          }

          handle {
            respond 404
          }
        '';
      };
    };

    proxies = {
      "e10.land" = {
        host = hosts.matrix;
        port = 8090;
        extraConfig = ''
          encode gzip zstd
        '';
      };

      "feeds.e10.camp" = {
        host = hosts.matrix;
        port = hosts.matrix.config.services.miniflux.config.PORT;
      };

      "prowlarr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.prowlarr.settings.server) port;
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

      "profilarr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.profilarr) port;
      };

      "incus.dill.e10.camp" = {
        host = hosts.dill;
        port = 8443;
        skipTLSVerify = true;
        extraReverseProxyConfig = ''
          header_up Host {http.request.host}
        '';
      };

      "sabnzbd.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.sabnzbd.settings.misc) port;
        extraConfig = ''
          request_body {
            max_size 256MiB
          }
        '';
      };

      "requests.e10.video" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.seerr) port;
        acme.environmentFile = config.sops.secrets.e10_video_lego_route53_credentials.path;
      };

      "tautulli.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.tautulli) port;
        acme.environmentFile = config.sops.secrets.e10_video_lego_route53_credentials.path;
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
        inherit (hosts.htpc.config.services.fileflows.server) port;
        protected = true;
      };

      "paperless.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.paperless) port;
        extraConfig = ''
          request_body {
            max_size 2GiB
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

      "cache.e10.camp" = {
        host = hosts.omnibus;
        port = 8080;
        extraConfig = ''
          encode gzip zstd

          request_body {
            max_size 10GiB
          }
        '';
      };

      "ldap.e10.camp" = {
        host = hosts.bastion;
        port = hosts.bastion.config.services.lldap.settings.http_port;
      };

      "pdf.e10.camp" = {
        host = hosts.matrix;
        inherit ((builtins.head hosts.matrix.config.services.bentopdf.nginx.virtualHost.listen)) port;
        protected = true;
      };

      "mazanoke.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.mazanoke) port;
        protected = true;
        extraConfig = ''
          request_body {
            max_size 2GiB
          }
        '';
      };

      "auth.e10.camp" = {
        host = hosts.bastion;
        port = 9091;
      };

      "speedtest-tracker.e10.camp" = {
        host = hosts.controller;
        port = 8881;
        # inherit (hosts.controller.config.services.speedtest-tracker) port;
      };

      "change-detection.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.changedetection-io) port;
        protected = true;
      };

      "tracearr.e10.camp" = {
        host = hosts.htpc;
        inherit (hosts.htpc.config.services.tracearr) port;
      };

      "bichon.e10.camp" = {
        host = hosts.matrix;
        inherit (hosts.matrix.config.services.bichon) port;
      };

      "jellyfin.e10.video" = {
        host = hosts.htpc;
        port = 8096;
        extraConfig = ''
          encode gzip zstd

          request_body {
            max_size 100MiB
          }
        '';
      };

      "karakeep.e10.camp" = {
        host = hosts.matrix;
        port = hosts.matrix.config.services.karakeep.extraEnvironment.PORT;
      };

      "hass.e10.camp" = {
        host = hosts.controller;
        port = hosts.controller.config.services.home-assistant.config.http.server_port;
      };

      "frigate.e10.camp" = {
        host = hosts.htpc;
        port = 8971;
      };

      "analytics.e10.camp" = {
        host = hosts.matrix;
        port = hosts.matrix.config.services.umami.settings.PORT;
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
            max_size 100MiB
          }
        '';
        extraReverseProxyConfig = ''
          header_up X-Real-IP {http.request.remote.host}

          transport http {
            read_buffer 0
            write_buffer 0
          }
        '';
      };
    };
  };
}
