{ lib, ... }:

with lib;

{
  options.services.radarr = {
    port = mkOption {
      type = types.port;
      description = "Port that Radrr is running on";
      default = 7878;
    };
  };
}
