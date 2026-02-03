{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.eufy-security-ws;
in {
  options.services.eufy-security-ws = {
    enable = mkEnableOption "Enable Eufy";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/eufy-security-ws";
    };

    host = mkOption {
      type = types.str;
      default = "localhost";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
    };

    configurationFile = mkOption { type = types.path; };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-eufy-security-ws" = {
      ${cfg.dataDir} = {
        "d" = {
          user = "eufy-security";
          group = "eufy-security";
          mode = "0700";
        };
      };
    };

    systemd.services.eufy-security-ws = {
      enable = true;
      description = "eufy-security-ws";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      reloadTriggers = [ cfg.configurationFile ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.eufy-security-ws}/bin/eufy-security-server \
            --config ${cfg.configurationFile} \
            --host ${cfg.host} \
            --port ${toString cfg.port}
        '';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        WorkingDirectory = "/var/lib/eufy-security-ws";
        User = "eufy-security";
        Group = "eufy-security";
        Restart = "on-failure";
        RestartForceExitStatus = "100";
        SuccessExitStatus = "100";
      };
    };

    users = {
      users.eufy-security = {
        isSystemUser = true;
        group = "eufy-security";
      };
      groups.eufy-security = { };
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;
  };
}
