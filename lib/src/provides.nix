{ lib, ... }:

with lib;

let
  # Get all services (entries in `provides`) from the given hosts
  allServicesForHosts = hosts:
    lib.pipe hosts [
      attrValues
      (map (host: host.config.provides or { }))
      (lib.foldl' (a: b: a // b) { })
    ];

  # Get all services that have HTTP proxy enabled
  allHTTPServices = services:
    filterAttrs (_name: value: value.http.proxy.enable) services;

  # Get all monitored services
  allMonitoredServices = services:
    filterAttrs (_name: value: value.http.monitor.enable) services;

  # Transform a set of services into Caddy virtual hosts
  caddyVirtualHostsForServices = caddyHost: services:
    mapAttrs' (name: attrs:
      let inherit (attrs) http;
      in nameValuePair http.proxy.domain (mkVirtualHost caddyHost name http))
    (filterAttrs (_name: attrs: attrs.http.proxy.enable) services);

  gatusEndpointsForServices = services:
    mapAttrsToList (_name: mkEndpoint)
    (filterAttrs (_name: attrs: attrs.monitor.proxy.enable) services);

  mkEndpoint = service:
    {
      enabled = true;
      alerts = [{
        enabled = true;
        type = "ntfy";
        description = "healthcheck failed";
        send-on-resolved = true;
      }];
    } // extraConfig // optionalAttrs service.http.proxy.protected {
      headers.Authorization = "Basic $AUTHELIA_BASIC_AUTH";
    };

  # Makes a single virtual host for HTTP service provides
  mkVirtualHost = caddyHost: name: http:
    let
      resolvedHost = if caddyHost.config.networking.hostName == http.host then
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
        output file ${caddyHost.config.services.caddy.logDir}/access-${name}.log {
          roll_size 1GiB
          roll_keep 0
          mode 777
        }
      '';

      extraConfig = ''
        ${optionalString http.proxy.protected autheliaForwardAuth}

        reverse_proxy ${resolvedHost}:${toString http.port} {
          ${http.proxy.extraReverseProxyConfig}
          ${
            optionalString http.proxy.skipTLSVerify ''
              transport http {
                tls_insecure_skip_verify
              }
            ''
          }
        }

        ${http.proxy.extraVirtualHostConfig}
      '';
    };
in {
  inherit allServicesForHosts allHTTPServices allMonitoredServices
    caddyVirtualHostsForServices gatusEndpointsForServices;
}
