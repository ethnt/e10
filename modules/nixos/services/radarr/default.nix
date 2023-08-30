{ lib, ... }:

with lib;

{
  options.services.radarr = {
    port = mkOption {
      type = types.port;
      description = "Port that Radarr is running on";
      default = 7878;
    };
  };
}
