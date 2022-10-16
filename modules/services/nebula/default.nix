{ config, lib, ... }:

with lib;

{
  options.services.nebula = {
    networks = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          address = mkOption {
            type = types.str;
            description = "Address inside of Nebula network";
          };
        };
      });
    };
  };
}
