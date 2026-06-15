{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.profilarr;
in {
  options.services.profilarr = {
    enable = mkEnableOption "Enable Profilarr";

    package = mkOption {
      type = types.package;
      default = pkgs.profilarr;
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "profilarr";
      description = "User to run Profilarr as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "profilarr";
      description = "Group to run Profilarr as";
    };

    port = mkOption {
      type = types.port;
      default = 3474;
      description = "Port that Profilarr is running on";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/profilarr";
      description = "Data directory for Profilarr";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Profilarr";
    };
  };

  config = mkIf cfg.enable {
    # systemd.tmpfiles.settings = {
    #   "10-profilarr" = {
    #     ${cfg.dataDir} = {
    #       d = {
    #         group = config.virtualisation.oci-containers.backend;
    #         user = config.virtualisation.oci-containers.backend;
    #         mode = "0777";
    #       };
    #     };
    #   };
    # };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    systemd.services.profilarr = {
      enable = true;
      environment = {
        APP_BASE_BATH = cfg.dataDir;
        PORT = toString cfg.port;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = lib.getExe pkgs.profilarr;
        StateDirectory = "profilarr";
        StateDirectoryMode = "0750";
        WorkingDirectory = cfg.dataDir;
      };
    };

    # virtualisation.oci-containers.containers.profilarr = {
    #   image = "santiagosayshey/profilarr:latest";
    #   ports = [ "${toString cfg.port}:6868" ];
    #   volumes = [ "${cfg.dataDir}:/config" ];
    #   environment.TZ = config.time.timeZone;
    # };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
