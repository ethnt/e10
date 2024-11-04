{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.borgmatic;
  settingsFormat = pkgs.formats.yaml { };
in {
  disabledModules = [ "services/backup/borgmatic.nix" ];

  options.services.borgmatic = {
    enable = mkEnableOption "Enable borgmatic";

    package = mkOption {
      type = types.package;
      default = pkgs.borgmatic;
    };

    configuration = mkOption {
      type = types.attrs;
      default = { };
    };

    configurations = mkOption {
      type =
        types.attrsOf (types.submodule { freeformType = settingsFormat.type; });
    };

    timer = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Borgmatic timer";

          calendar = mkOption { type = types.str; };
        };
      };
      default = { };
    };

    enableConfigCheck = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = let
    recursiveMerge = attrList:
      let
        f = attrPath:
          zipAttrsWith (n: values:
            if tail values == [ ] then
              head values
            else if all isList values then
              unique (concatLists values)
            else if all isAttrs values then
              f (attrPath ++ [ n ]) values
            else
              last values);
      in f [ ] attrList;
    configFiles = mapAttrs' (name: value:
      nameValuePair "borgmatic.d/${name}.yaml" {
        source = settingsFormat.generate "${name}.yaml"
          (recursiveMerge [ cfg.configuration value ]);
      }) cfg.configurations;
    borgmaticCheck = name: f:
      pkgs.runCommandCC "${name} validation" { } ''
        ${pkgs.borgmatic}/bin/borgmatic -c ${f.source} config validate
        touch $out
      '';
  in mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc = configFiles;

    systemd.packages = [ cfg.package ];

    systemd.timers.borgmatic = mkIf cfg.timer.enable {
      enable = true;
      description = "borgmatic automatic backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "borgmatic.service";
        OnCalendar = cfg.timer.calendar;
        Persistent = true;
        WakeSystem = true;
      };
    };

    system.checks =
      mkIf cfg.enableConfigCheck (mapAttrsToList borgmaticCheck configFiles);
  };
}
