{ flake, config, lib, ... }:

with lib;

let nixosConfig = config;
in {
  options.provides = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          description = "Display name of this service";
        };

        http = mkOption {
          type = types.submodule {
            options = {
              host = mkOption {
                type = types.str;
                description = "The host of this HTTP service";
                default = nixosConfig.networking.hostName;
              };

              port = mkOption {
                type = types.oneOf [ types.port types.str ];
                description = "The port of this HTTP service";
              };

              proxy = mkOption {
                type = types.submodule {
                  options = {
                    enable = mkEnableOption
                      "Enable HTTP reverse proxy for this service";

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
                            description =
                              "DNS provider for the ACME certificate";
                          };
                          environmentFile = mkOption {
                            type = types.path;
                            description =
                              "Environment file for the ACME certificate";
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
                default = { };
              };
            };
          };
        };

        monitor = mkOption {
          type = types.submodule {
            options = {
              enable = mkEnableOption
                "Enabling monitoring of this service using Gatus";

              name = mkOption {
                type = types.str;
                description = "Name of the service being monitored";
                default = config.name;
              };

              url = mkOption {
                type = types.str;
                description = "URL of the service to monitor";
                default = if config.http.proxy.enable then
                  (if config.http.proxy.skipTLSVerify then
                    "http://${config.http.proxy.domain}"
                  else
                    "https://${config.http.proxy.domain}")
                else
                  "http://${config.http.host}:${toString config.http.port}";
              };

              group = mkOption {
                type = types.str;
                description = "Group to put the monitor in";
                default = flake.lib.strings.capitalizeString
                  nixosConfig.networking.hostName;
              };

              conditions = mkOption {
                type = types.listOf types.str;
                description =
                  "List of Gatus conditions to evaluate if the service is healthy";
                default = [ "[STATUS] == 200" ];
              };

              interval = mkOption {
                type = types.str;
                description = "Interval to check if the service is healthy";
                default = "60s";
              };

              extraConfig = mkOption {
                type = types.attrs;
                description = "Extra config for the Gatus endpoint";
                default = { };
              };
            };
          };
          default = { };
        };
      };
    }));
    default = { };
  };
}
