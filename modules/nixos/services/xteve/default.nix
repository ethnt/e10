{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.xteve;
in {
  options.services.xteve = {
    enable = mkEnableOption "Enable xTeVe";

    package = mkOption {
      type = types.package;
      default = pkgs.xteve;
    };

    user = mkOption {
      type = types.str;
      default = "xteve";
    };

    group = mkOption {
      type = types.str;
      default = "xteve";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/xteve";
    };

    port = mkOption {
      type = types.port;
      default = 34400;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
      "d '/tmp/xteve' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    users.users = mkIf (cfg.user == "xteve") {
      xteve = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        uid = 3440;
      };
    };

    users.groups = mkIf (cfg.group == "xteve") { xteve.gid = 3440; };

    systemd.services.xteve = {
      description = "xTeVe";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''
          ${cfg.package}/bin/xteve \
            -config ${cfg.dataDir} \
            -port ${toString cfg.port}
        '';
        Restart = "on-failure";
      };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
