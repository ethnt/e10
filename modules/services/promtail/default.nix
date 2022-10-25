{ lib, ... }:

with lib;

{
  options.services.promtail = {
    host = mkOption {
      type = types.str;
      description = "Label of host running this instance of Promtail";
    };
  };
}
