{ config, lib, ... }:

with lib;

{
  options.deployment = {
    deployable = mkOption {
      type = types.bool;
      description = "Should we deploy this node to a host?";
      default = true;
    };

    vmType = mkOption {
      type = types.nullOr (
        types.enum [
          "proxmox"
          "incus"
          "aws-ec2"
        ]
      );
      description = "What type of VM this node is";
    };
  };

  config = {
    deployment.targetHost = mkDefault config.networking.hostName;
  };
}
