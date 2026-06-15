{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.mazanoke;
in {
  options.services.mazanoke = {
    enable = mkEnableOption "Enable Mazanoke";

    package = mkOption {
      type = types.package;
      default = pkgs.mazanoke;
      description = "Package containing Mazanoke";
    };

    user = mkOption {
      type = types.str;
      default = "mazanoke";
      description = "User to run Mazanoke under";
    };

    group = mkOption {
      type = types.str;
      default = "mazanoke";
      description = "Group to run Mazanoke under";
    };

    port = mkOption {
      type = types.port;
      default = 3474;
      description = "Port that Mazanoke is running on";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Mazanoke";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mazanoke = {
      description = "Mazanoke image optimizer";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          "${lib.getExe pkgs.darkhttpd} ${cfg.package}/share/mazanoke --port ${
            toString cfg.port
          }";
        Restart = "always";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    users = {
      users.mazanoke = mkIf (cfg.user == "mazanoke") {
        inherit (cfg) group;
        isSystemUser = true;
      };

      groups = mkIf (cfg.group == "mazanoke") { mazanoke = { }; };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
