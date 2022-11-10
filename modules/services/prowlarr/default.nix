{ lib, ... }:

with lib;

{
  options.services.prowlarr = {
    port = mkOption {
      type = types.port;
      description = "Port that Prowlarr is running on";
      default = 9696;
    };
  };
}
