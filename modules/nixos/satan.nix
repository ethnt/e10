{ lib, ... }:

with lib;

{
  options.satan = {
    address = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Private network address within local network";
    };

    networkInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Primary network interface";
    };
  };
}
