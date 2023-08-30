{ config, lib, ... }:

with lib;

{
  options.e10 = {
    name = mkOption {
      type = types.str;
      description = "Name of this host";
      default = config.networking.hostName;
    };

    privateAddress = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Private network address (within VPC or local network)";
    };

    publicAddress = mkOption {
      type = types.str;
      description = "Public address on the internet";
    };

    domain = mkOption {
      type = types.str;
      description = "Domain name for this host";
    };

    deployable = mkOption {
      type = types.bool;
      description = "Should we deploy to this host?";
      default = true;
    };
  };
}
