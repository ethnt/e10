{ flake, config, lib, hosts, ... }: {
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
    virtualHosts = let
      providedVirtualHosts =
        flake.lib.provides.caddyVirtualHostsForServices hosts.bastion
        (flake.lib.provides.allHTTPServices
          (flake.lib.provides.allServicesForHosts
            (lib.filterAttrs (name: _value: name != "monitor")
              flake.nixosConfigurations)));
    in {
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
    } // providedVirtualHosts;
  };
}
