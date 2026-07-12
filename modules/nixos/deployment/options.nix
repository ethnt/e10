{ config, lib, ... }:

with lib;

{
  options.deployment = {
    deployable = mkOption {
      type = types.bool;
      description = "Should we deploy this node to a host?";
      default = true;
    };

    incusVirtualMachine = mkOption {
      type = types.bool;
      description = "Is this an Incus VM?";
      default = false;
    };
  };

  config = {
    deployment.targetHost = mkDefault config.networking.hostName;
  };
}
