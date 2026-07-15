{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.prometheus.exporters.dcgm-exporter;
  wrapper = pkgs.buildFHSEnv {
    name = "dcgm-exporter";
    targetPkgs =
      pkgs: with pkgs; [
        cfg.package
        config.hardware.nvidia.package
        dcgm
        glibc
        stdenv.cc.cc.lib
      ];
    runScript = "dcgm-exporter";
    extraBuildCommands = ''
      mkdir -p sbin
      ln -s /usr/bin/ldconfig sbin/ldconfig
    '';
  };
in
{
  options.services.prometheus.exporters.dcgm-exporter = {
    enable = mkEnableOption "Enable dcgm exporter";

    package = mkOption {
      type = types.package;
      description = "Package to use";
      default = pkgs.prometheus-dcgm-exporter;
    };

    port = mkOption {
      type = types.port;
      description = "Port to listen on";
      default = 9400;
    };

    metricsFile = mkOption {
      type = types.path;
      description = "CSV containing the fields that will be exposed";
      default = ./default-counters.csv;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Open the port in the firewall";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.prometheus-dcgm-exporter = {
      description = "prometheus-dcgm-exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        NVIDIA_DRIVER_CAPABILITIES = "all";
        NVIDIA_VISIBLE_DEVICES = "all";
      };
      serviceConfig = {
        ExecStart = "${lib.getExe wrapper} --address=0.0.0.0:${toString cfg.port} -f ${cfg.metricsFile}";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
        SupplementaryGroups = [ "video" ];
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };

    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
