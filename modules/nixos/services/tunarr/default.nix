{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.tunarr;
in
{
  options.services.tunarr = {
    enable = mkEnableOption "tunarr";

    package = mkOption {
      type = types.package;
      default = pkgs.tunarr;
    };

    user = mkOption {
      type = types.str;
      default = "tunarr";
    };

    group = mkOption {
      type = types.str;
      default = "tunarr";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tunarr";
    };

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 8000;
    };

    logLevel = {
      type = types.str;
      default = "info";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;

    systemd.tmpfiles.settings."10-tunarr" = {
      ${cfg.dataDir} = {
        "d" = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };
    };

    users = {
      users.tunarr = mkIf (cfg.user == "tunarr") {
        inherit (cfg) group;
        isSystemUser = true;
      };

      groups = mkIf (cfg.group == "tunarr") {
        tunarr = { };
      };
    };

    systemd.services.tunarr = {
      description = "Tunarr personal TV server";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = cfg.dataDir;
        TZ = config.time.timeZone;
        TUNARR_BIND_ADDR = cfg.bindAddress;
        TUNARR_DATABASE_PATH = cfg.dataDir;
        TUNARR_LOG_LEVEL = cfg.logLevel;
        TUNARR_SERVER_PORT = toString cfg.port;
      };
      serviceConfig =
        let
          updateSettings = pkgs.writeShellScript "tunarr-update-settings" ''
            exec ${lib.getExe cfg.package} --database ${cfg.dataDir} settings update \
              --settings.ffmpeg.ffmpegExecutablePath=${lib.getExe cfg.package.ffmpeg} \
              --settings.ffmpeg.ffprobeExecutablePath=${lib.getExe' cfg.package.ffmpeg "ffprobe"} \
              >/dev/null
          '';
        in
        {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${lib.getExe cfg.package} --database ${cfg.dataDir}";
          ExecStartPre = updateSettings;
          ReadWritePaths = [ cfg.dataDir ];
          Restart = "on-failure";
          RestartSec = "5s";
          StateDirectory = "tunarr";
          StateDirectoryMode = "0700";
          UMask = "0077";
          WorkingDirectory = cfg.dataDir;
        };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
