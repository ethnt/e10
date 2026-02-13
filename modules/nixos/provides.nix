{ lib, ... }:

with lib;

{
  options.provides = {
    services = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the service";
          };

          http = mkOption {
            type = types.submodule {
              options = {
                port = mkOption {
                  type = types.oneOf [ types.port types.str ];
                  description = "Port that the HTTP service is listening on";
                };

                proxy = mkOption {
                  type = types.submodule {
                    options = {
                      enable =
                        mkEnableOption "Configuration for HTTP reverse proxy";

                      domain = mkOption {
                        type = types.str;
                        description = "Domain for the reverse proxy";
                      };

                      protected = mkOption {
                        type = types.bool;
                        description =
                          "If the HTTP reverse proxy should be behind authentication";
                        default = false;
                      };
                    };
                  };
                };
              };
            };
            default = { };
            description = "HTTP configuration for the service";
          };

          monitor = mkOption {
            type = types.submodule {
              options = {
                enable = mkEnableOption "Enable monitoring of this service";
              };
            };
          };

          dashboard = mkOption {
            type = types.submodule {
              options = {
                enable =
                  mkEnableOption "Enable link of this service on a dashboard";

                icon = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "Icon to use in Glance";
                };
              };
            };
          };
        };
      });
    };
  };
}
