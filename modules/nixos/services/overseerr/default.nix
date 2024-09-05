{ config, pkgs, lib, ... }:

with lib;

let cfg = config.services.overseerr;
in {
  options.services.overseerr = {
    enable = mkEnableOption "Enable Overseerr";

    package = mkOption {
      type = types.package;
      default = pkgs.overseerr;
    };

    port = mkOption {
      type = types.port;
      description = "Port for Overseerr to listen on";
      default = 5055;
    };

    openFirewall = mkOption {
      type = types.bool;
      description =
        "Open ports in the firewall for the Overseerr web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [ "d '/var/lib/overseerr' 0777 nobody nogroup - -" ];

    systemd.services.overseerr = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment.PORT = toString cfg.port;
      serviceConfig = {
        Type = "exec";
        StateDirectory = "overseerr";
        WorkingDirectory = "${cfg.package}/libexec/overseerr/deps/overseerr";
        ExecStart = lib.getExe cfg.package;
        BindPaths = [
          "/var/lib/overseerr/:${cfg.package}/libexec/overseerr/deps/overseerr/config/"
        ];
        Restart = "on-failure";
      };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
