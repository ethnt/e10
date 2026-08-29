{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.wizarr;
in
{
  options.services.wizarr = {
    enable = mkEnableOption "Wizarr";

    package = mkPackageOption pkgs "wizarr" { };

    user = mkOption {
      type = types.str;
      description = "User to run Wizarr under";
      default = "wizarr";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run Wizarr under";
      default = "wizarr";
    };

    host = mkOption {
      type = types.str;
      description = "Bind address for Wizarr";
      default = "0.0.0.0";
    };

    port = mkOption {
      type = types.port;
      description = "Port for Wizarr to listen on.";
      default = 5690;
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory for Wizarr";
      default = "/var/lib/wizarr";
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Whether to open the firewall for Wizarr";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.wizarr = mkIf (cfg.user == "wizarr") {
        isSystemUser = true;
        group = "wizarr";
        home = cfg.dataDir;
      };

      groups = mkIf (cfg.group == "wizarr") {
        wizarr = { };
      };
    };

    systemd.tmpfiles.settings."10-wizarr" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };
    };

    systemd.services.wizarr = {
      description = "Wizarr media server invitation manager";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = cfg.dataDir;
        TZ = config.time.timeZone;
        WIZARR_PORT = toString cfg.port;
        FLASK_SKIP_SCHEDULER = "true";
      };

      preStart = ''
        ${lib.getExe' cfg.package "wizarr-migrate"} db upgrade
      '';

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.user;
        ReadWritePaths = cfg.dataDir;
        StateDirectory = "wizarr";
        CacheDirectory = "wizarr";
        ExecStart = ''
          ${lib.getExe cfg.package} \
            --bind ${cfg.host}:${toString cfg.port} \
            --umask 007
        '';
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;

        # Wizarr hardcodes `/data/database` whenever `/data` exists, so give it
        # a fake `/data/database` symlinked to `/var/lib/wizarr`
        TemporaryFileSystem = "/data";
        BindPaths = "${cfg.dataDir}:/data/database";
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
