{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.subgen;
in
{
  options.services.subgen = {
    enable = mkEnableOption "Subgen";

    package = mkOption {
      type = types.package;
      default = pkgs.subgen;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/subgen";
    };

    modelDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/models";
    };

    modelPackage = mkOption {
      type = types.package;
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = mkOption {
      type = types.port;
      default = 9000;
    };

    computeType = mkOption {
      type = types.str;
      default = "int8";
    };

    threads = mkOption {
      type = types.ints.positive;
      default = 4;
    };

    transcribeDevice = mkOption {
      type = types.enum [
        "cpu"
        "gpu"
        "cuda"
      ];
      default = "cpu";
    };

    transcribeOrTranslate = mkOption {
      type = types.enum [
        "transcribe"
        "translate"
      ];
      default = "transcribe";
    };

    concurrentTranscriptions = mkOption {
      type = types.ints.positive;
      default = 1;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.subgen = {
      description = "Subgen subtitle generation";

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        WEBHOOK_HOST = cfg.listenAddress;
        WEBHOOK_PORT = toString cfg.port;
        WHISPER_MODEL = toString cfg.modelPackage;
        MODEL_PATH = cfg.modelDir;
        TRANSCRIBE_DEVICE = cfg.transcribeDevice;
        TRANSCRIBE_OR_TRANSLATE = cfg.transcribeOrTranslate;
        COMPUTE_TYPE = cfg.computeType;
        WHISPER_THREADS = toString cfg.threads;
        CONCURRENT_TRANSCRIPTIONS = toString cfg.concurrentTranscriptions;
        PROCESS_ADDED_MEDIA = "False";
        PROCESS_MEDIA_ON_PLAY = "False";
        MONITOR = "False";
        RELOAD_SCRIPT_ON_CHANGE = "False";
        UPDATE = "False";
        DEBUG = "True";
      };

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "subgen";
        StateDirectoryMode = "0700";
        WorkingDirectory = cfg.dataDir;
        UMask = "0077";

        NoNewPrivileges = true;
        PrivateDevices = false;
        DevicePolicy = "closed";
        DeviceAllow = [
          "char-nvidiactl"
          "char-nvidia-caps"
          "char-nvidia-frontend"
          "char-nvidia-uvm"
        ];
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        CapabilityBoundingSet = "";
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
      };
    };

    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;
  };
}
