{ config, lib, ... }:

with lib;

let cfg = config.services.caddy-proxy;
in {
  options.services.caddy-proxy = {
    enable = mkEnableOption "Enable proxying with Caddy";

    proxies = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption { type = types.attrs; };
          port = mkOption { type = types.oneOf [ types.port types.str ]; };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
          };
          protected = mkOption {
            type = types.bool;
            default = false;
          };
          acme = mkOption {
            type = types.submodule {
              options = {
                generate = mkOption {
                  type = types.bool;
                  default = false;
                };
                provider = mkOption {
                  type = types.str;
                  default = null;
                };
                environmentFile = mkOption {
                  type = types.path;
                  default = null;
                };
              };
            };
            default = { };
          };
        };
      });
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.caddy = { enable = true; };

    services.caddy.virtualHosts = mapAttrs (name: value:
      let
        resolvedHost = if config.networking.hostName
        == value.host.config.networking.hostName then
          "localhost"
        else
          value.host.config.networking.hostName;
        autheliaForwardAuth = ''
          forward_auth localhost:9091 {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }
        '';
      in {
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-${name}.log {
            roll_size 1GiB
            roll_keep 0
            mode 777
          }
        '';
        extraConfig = ''
          ${optionalString value.protected autheliaForwardAuth}

          reverse_proxy ${resolvedHost}:${toString value.port}

          ${value.extraConfig}
        '';
      } // lib.optionalAttrs value.acme.generate { useACMEHost = name; })
      cfg.proxies;

    security.acme.certs = mapAttrs (name: value: {
      domain = name;
      extraDomainNames = [ "*.${name}" ];
      dnsProvider = value.acme.provider;
      inherit (value.acme) environmentFile;
      group = "caddy";
    }) (filterAttrs (_name: value: value.acme.generate) cfg.proxies);
  };
}
