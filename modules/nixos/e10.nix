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
      type = types.str;
      description = "Private address within our own network";
    };

    publicAddress = mkOption {
      type = types.str;
      description = "Public address on the internet";
    };

    domain = mkOption {
      type = types.str;
      description = "Domain name for this host";
    };
  };
}
