{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.bichon;
  environment = {
    BICHON_ROOT_DIR = cfg.dataDir;
    BICHON_HTTP_PORT = toString cfg.port;
    BICHON_BIND_IP = cfg.listenAddress;
  };
in {
  options.services.bichon = {
    enable = mkEnableOption "Enable Bichon";

    package = mkOption {
      type = types.package;
      description = "Package to use for Bichon";
      default = pkgs.bichon;
    };

    user = mkOption {
      type = types.str;
      description = "User to run Bichon under";
      default = "bichon";
    };

    group = mkOption {
      type = types.str;
      description = "Group to run Bichon under";
      default = "bichon";
    };

    listenAddress = mkOption {
      type = types.str;
      description = "Address for the Bichon server to listen on";
      default = "0.0.0.0";
    };

    port = mkOption {
      type = types.port;
      description = "Port for the Bichon server to listen on";
      default = 15630;
    };

    dataDir = mkOption {
      type = types.path;
      description = "Data directory";
      default = "/var/lib/bichon";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.bichon = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      inherit environment;

      serviceConfig = {
        StateDirectory = cfg.dataDir;
        ExecStart = lib.getExe cfg.package;
      };
    };

    users = {
      users."${cfg.user}" = {
        inherit (cfg) group;
        isSystemUser = true;
        linger = true;
      };

      groups."${cfg.group}" = { };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall 15630;
  };
}
