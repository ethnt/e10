{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.prometheus.exporters.plex-media-server;
in {
  options.services.prometheus.exporters.plex-media-server = {
    enable = mkEnableOption "Enable Plex Media Server exporter";

    package = mkOption {
      type = types.package;
      description = "Which package to use for the exporter";
      default = pkgs.prometheus-plex-exporter;
    };

    port = mkOption {
      type = types.port;
      description =
        "Port to expose for this exporter. It's hardcoded, so this is only here for convencience";
      default = 9000;
    };

    user = mkOption {
      type = types.str;
      default = "prometheus-plex-exporter";
    };

    group = mkOption {
      type = types.str;
      default = "prometheus-plex-exporter";
    };

    url = mkOption {
      type = types.str;
      description = "URL of the Plex server to monitor";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to a secrets file containing the Plex token";
    };

    libraryRefreshInterval = mkOption {
      type = types.int;
      description =
        "How often to re-query expensive per-library counts (music tracks, episode counts, and library items) in minutes. Must be an integer number of minutes. Defaults to 15 when unset. Set to 0 to disable caching and always re-query";
      default = 15;
    };

    logLevel = mkOption {
      type = types.str;
      description =
        "Log verbosity. One of `debug`, `info`, `warn`, `error`. Defaults to `info`. Set to `debug` for verbose troubleshooting";
      default = "info";
    };

    logFormat = mkOption {
      type = types.str;
      description =
        "Log output format. Set to `console` for human-readable logs (development), or omit for structured JSON logs (production/containers)";
      default = "json";
    };

    envrionmentMode = mkOption {
      type = types.str;
      description =
        "Environment mode. Set to `development` for console logging, or omit for production JSON logging";
      default = "production";
    };

    skipTLSVerification = mkOption {
      type = types.bool;
      description =
        "Optional convenience for connecting to Plex servers with self-signed or mismatched TLS certificates. When set to true the exporter (and the vendored Plex client) will skip TLS certificate verification for both HTTP and websocket connections. THIS IS INSECURE — only use in trusted networks or testing. Defaults to off";
      default = false;
    };

    clientTimeoutSeconds = mkOption {
      type = types.int;
      description =
        "HTTP client timeout when contacting the Plex server (seconds). Defaults to `10`. Set higher for slow LANs or when your Plex server takes longer to respond (mostly due to size)";
      default = 10;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Whether or not to open the firewall for the exporter";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.prometheus-plex-exporter =
        mkIf (cfg.user == "prometheus-plex-exporter") {
          inherit (cfg) group;
          isSystemUser = true;
        };

      groups = mkIf (cfg.group == "prometheus-plex-exporter") {
        prometheus-plex-exporter = { };
      };
    };

    systemd.services.prometheus-plex-exporter = {
      enable = true;
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PLEX_SERVER = cfg.url;
        LIBRARY_REFRESH_INTERVAL = toString cfg.libraryRefreshInterval;
        LOG_LEVEL = cfg.logLevel;
        LOG_FORMAT = cfg.logFormat;
        ENVIRONMENT_MODE = cfg.envrionmentMode;
        SKIP_TLS_VERIFICATION =
          if cfg.skipTLSVerification then "true" else "false";
        CLIENT_TIMEOUT_SECONDS = toString cfg.clientTimeoutSeconds;
      };
      serviceConfig = {
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "prometheus-plex-exporter-exec-start";
          text = ''
            export PLEX_TOKEN

            PLEX_TOKEN=$(cat ${cfg.tokenFile})

            ${lib.getExe' cfg.package "prometheus-plex-exporter"}
          '';
        });
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
