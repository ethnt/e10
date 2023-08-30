{ lib, ... }:

with lib;

{
  options.services.sonarr = {
    port = mkOption {
      type = types.port;
      description = "Port that Sonarr is running on";
      default = 8989;
    };
  };
}
