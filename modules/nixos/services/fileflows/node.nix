{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.fileflows.node;
in {
  options.services.fileflows.node = {
    enable = mkEnableOption "Enable FileFlows node";

    package = mkOption {
      type = types.package;
      default = pkgs.fileflows;
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

    serverUrl = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-fileflows-node" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };

      "${cfg.binDir}"."L+".argument = "${
          pkgs.symlinkJoin {
            name = "fileflows-node-extra-pkgs";
            paths = cfg.extraPkgs;
          }
        }/bin";
    };

    systemd.services.fileflows-server = {
      description = "FileFlows node";
      script =
        "${cfg.package}/bin/node --no-gui --systemd-service --server ${cfg.serverUrl}";
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
