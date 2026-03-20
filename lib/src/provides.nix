{ lib, ... }:

with lib;

let
  # Get all services (entries in `provides`) from the given hosts
  allServices = hosts:
    lib.pipe hosts [
      attrValues
      (map (host: host.config.provides or { }))
      (lib.foldl' (a: b: a // b) { })
    ];

  # Get all services that have HTTP enabled
  allHTTPServices = services:
    filterAttrs (_name: value: value.http.enable) services;

  # Transform a set of services into Caddy virtual hosts
  caddyVirtualHostsForServices = caddyHost: services:
    mapAttrs' (name: attrs:
      let inherit (attrs) http;
      in nameValuePair http.domain (mkVirtualHost caddyHost name http))
    services;

  # Makes a single virtual host for HTTP service provides
  mkVirtualHost = caddyHost: name: http:
    let
      resolvedHost = if caddyHost.networking.hostName == http.host then
        "localhost"
      else
        http.host;
      autheliaForwardAuth = ''
        forward_auth localhost:9091 {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      '';
    in {
      logFormat = ''
        output file ${caddyHost.services.caddy.logDir}/access-${name}.log {
          roll_size 1GiB
          roll_keep 0
          mode 777
        }
      '';

      extraConfig = ''
        ${optionalString http.protected autheliaForwardAuth}

        reverse_proxy ${resolvedHost}:${toString http.port} {
          ${http.extraReverseProxyConfig}
          ${
            optionalString http.skipTLSVerify ''
              transport http {
                tls_insecure_skip_verify
              }
            ''
          }
        }

        ${http.extraVirtualHostConfig}
      '';
    };
in { inherit allServices allHTTPServices caddyVirtualHostsForServices; }
