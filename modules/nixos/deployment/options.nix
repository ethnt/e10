{ config, lib, ... }:

with lib;

{
  options.deployment = {
    deployable = mkOption {
      type = types.bool;
      description = "Should we deploy this node to a host?";
      default = true;
    };
  };

  config = { deployment.targetHost = mkDefault config.networking.hostName; };
}
