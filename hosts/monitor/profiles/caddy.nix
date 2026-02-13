{ config, lib, ... }: {
  services.caddy = {
    virtualHosts = let
      autheliaForwardAuth = ''
        forward_auth localhost:9091 {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      '';
    in lib.mapAttrs' (_name: value:
      lib.attrsets.nameValuePair value.http.proxy.domain {
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-${value.http.proxy.domain}.log {
            roll_size 1GiB
            roll_keep 0
            mode 777
          }
        '';
        extraConfig = ''
          ${lib.optionalString value.http.proxy.protected autheliaForwardAuth}

          reverse_proxy localhost:${toString value.http.port} {
            ${value.http.proxy.extraProxyConfig}
            ${
              lib.optionalString value.http.proxy.skipTLSVerify ''
                transport http {
                  tls_insecure_skip_verify
                }
              ''
            }
          }

          ${value.http.proxy.extraConfig}
        '';
      } // (lib.optionalAttrs value.http.proxy.acme.generate {
        useACHMEHost = value.http.proxy.domain;
      })) (lib.filterAttrs (_: value: value.http.proxy.enable)
        config.provides.services);
    # proxies = lib.mapAttrs' (_name: value:
    #   lib.attrsets.nameValuePair value.http.proxy.domain {
    #     host = hosts.monitor;
    #     inherit (value.http) port;
    #     inherit (value.http.proxy) protected extraConfig;
    #   }) (lib.filterAttrs (_: value: value.http.proxy.enable)
    #     config.provides.services);
  };
}
