{ config, lib, ... }:

with lib;

let cfg = config.services.speedtest-tracker;
in {
  options.services.speedtest-tracker = {
    enable = mkEnableOption "Enable Speedtest Tracker container";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/speedtest-tracker";
    };

    port = mkOption {
      type = types.port;
      description = "HTTP port";
      default = 8881;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };

    schedule = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    servers = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0777 ${config.virtualisation.oci-containers.backend} ${config.virtualisation.oci-containers.backend} - -"
    ];

    virtualisation.oci-containers.containers.speedtest-tracker = {
      image = "lscr.io/linuxserver/speedtest-tracker:latest";
      environment = {
        TZ = config.time.timeZone;
        APP_KEY = "base64:0WtY+fn4Qc5W3S7EX8sad44ClN32KZ11aoU2f9yxiTo=";
        SPEEDTEST_SCHEDULE = lib.optionals (cfg.schedule != null) cfg.schedule;
        SPEEDTEST_SERVERS =
          lib.optionals (cfg.servers != null) lib.strings.concatStringsSep ","
          cfg.servers;
      };
      volumes = [ "${cfg.dataDir}:/config" ];
      ports = [ "${toString cfg.port}:80" ];
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
