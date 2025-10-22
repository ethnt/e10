{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.fileflows.server;
in {
  options.services.fileflows.server = {
    enable = mkEnableOption "Enable FileFlows server";

    package = mkOption {
      type = types.package;
      default = pkgs.fileflows;
    };

    port = mkOption {
      type = types.port;
      description = "Port for FileFlows to listen on";
      default = 19200;
    };

    dataDir = mkOption {
      type = types.path;
      description = "Path to store FileFlows files in";
      default = "/var/lib/fileflows";
    };

    user = mkOption {
      type = types.str;
      description = "User to run FileFlows";
      default = "fileflows";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run FileFlows";
      default = "fileflows";
    };

    extraPkgs = mkOption {
      type = types.listOf types.package;
      description = "Extra packages for FileFlows";
      default = [ ];
    };

    binDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/bin";
    };

    libraryDirs = mkOption {
      type = types.listOf types.path;
      default = [ ];
    };

    openFirewall = mkOption {
      type = types.bool;
      description =
        "Open ports in the firewall for the FileFlows web interface";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-fileflows-server" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };

      "${cfg.binDir}"."L+".argument = "${
          pkgs.symlinkJoin {
            name = "fileflows-server-extra-pkgs";
            paths = cfg.extraPkgs;
          }
        }/bin";
    };

    systemd.services.fileflows-server = {
      description = "FileFlows server";
      script =
        "${cfg.package}/bin/server --no-gui --systemd-service --urls=http://[::]:${
          toString cfg.port
        }";
      environment.FILEFLOWS_SERVER_BASE_DIR = cfg.dataDir;

      serviceConfig = {
        Type = "simple";

        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";

        ReadWritePaths = [ cfg.dataDir ] ++ cfg.libraryDirs;
        ReadOnlyPaths = [ cfg.binDir ];
        BindReadOnlyPaths = [ "${cfg.binDir}:/bin" ];
      };

      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    users = {
      users = mkIf (cfg.user == "fileflows") {
        fileflows = {
          isSystemUser = true;
          home = cfg.dataDir;
          inherit (cfg) group;
        };
      };

      groups = mkIf (cfg.group == "fileflows") { fileflows = { }; };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
