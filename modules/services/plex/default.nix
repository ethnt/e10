{ lib, ... }:

with lib;

{
  options.services.plex = {
    port = mkOption {
      type = types.port;
      description = "Port that Plex is running on";
      default = 32400;
    };
  };
}
