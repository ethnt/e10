{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.xteve;
in {
  options.services.xteve = {
    enable = mkEnableOption "Enable xTeVe";

    package = mkOption {
      type = types.package;
      description = "Package to use for xTeVe";
      default = pkgs.xteve;
    };

    port = mkOption {
      type = types.port;
      description = "Port to run xTeVe on";
      default = 34400;
    };

    user = mkOption {
      type = types.str;
      description = "User to run xTeVe";
      default = "xteve";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run xTeVe";
      default = "xteve";
    };

    configDir = mkOption {
      type = types.path;
      description = "Path for xTeVe configuration files";
      default = "/var/lib/xteve";
    };

    openFirewall = mkOption {
      type = types.bool;
      description =
        "If the firewall should allow traffic on the port for xTeVe";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    users.users = mkIf (cfg.user == "xteve") {
      xteve = {
        inherit (cfg) group;
        home = cfg.configDir;
        uid = 325;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.user == "xteve") { xteve.gid = 325; };

    systemd.services.xteve = {
      description = "M3U Proxy for Plex DVR and Emby Live TV";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "xteve";
        Group = "xteve";
        ExecStart = "${cfg.package}/bin/xteve -port=${
            toString cfg.port
          } -config=${cfg.configDir}";
      };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
