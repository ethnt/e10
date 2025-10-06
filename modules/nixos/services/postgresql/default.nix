{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.postgresql;

in {
  options.services.postgresql = {
    initialScriptText = mkOption {
      type = types.lines;
      description =
        "SQL to run on the initial start of PostgreSQL. This will get packaged into `services.postgresql.initialScript`";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql.initialScript = mkDefault
      (pkgs.writeText "postgresql-initial-script" cfg.initialScriptText);
  };
}
