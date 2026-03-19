{ config, lib, ... }:

with lib;

{
  options.provides = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Display name of this service";
        };

        http = mkOption {
          type = types.submodule {
            options = {
              enable = mkEnableOption "Enable HTTP provider for service";

              host = mkOption {
                type = types.str;
                description = "The host of this HTTP service";
                default = config.networking.hostName;
              };

              port = mkOption {
                type = types.oneOf [ types.port types.str ];
                description = "The port of this HTTP service";
              };

              domain = mkOption {
                type = types.str;
                description = "The domain requested for this service";
              };

              protected = mkOption {
                type = types.bool;
                description =
                  "Should this service be behind authentication server?";
                default = false;
              };

              skipTLSVerify = mkOption {
                type = types.bool;
                description = "Should we skip TLS verification?";
                default = false;
              };

              acme = mkOption {
                type = types.submodule {
                  options = {
                    generate = mkOption {
                      type = types.bool;
                      description =
                        "Should we create an ACME certification separate from the one created by Caddy?";
                      default = false;
                    };
                    provider = mkOption {
                      type = types.str;
                      description = "DNS provider for the ACME certificate";
                    };
                    environmentFile = mkOption {
                      type = types.path;
                      description = "Environment file for the ACME certificate";
                    };
                  };
                };
                description = "ACME configuration for the reverse proxy";
                default = { };
              };

              extraVirtualHostConfig = mkOption {
                type = types.lines;
                description = "Extra Caddy virtual host configuration";
                default = "";
              };

              extraReverseProxyConfig = mkOption {
                type = types.lines;
                description = "Extra caddy reverse proxy configuration";
                default = "";
              };
            };
          };
        };
      };
    });
    default = { };
  };
}
