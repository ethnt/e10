{ config, lib, ... }:

with lib;

{
  options.networkMap = mkOption {
    type = types.attrs;
    default = { };
  };
}
