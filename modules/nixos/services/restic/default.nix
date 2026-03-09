{ config, lib, pkgs, ... }:

with lib;

{
  options.services.restic.backups = mkOption {
    type = types.attrsOf (types.submodule (_: {
      options.exporter = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "Enable Prometheus exporter";
            port = mkOption {
              type = types.port;
              default = 9754;
            };
          };
        };
        default = { };
      };
    }));
  };

  config = {
    systemd.services = mkMerge (mapAttrsToList (name: backup:
      optionalAttrs backup.exporter.enable {
        "prometheus-restic-exporter-${name}" = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          script = ''
            export RESTIC_PASSWORD_FILE=$CREDENTIALS_DIRECTORY/RESTIC_PASSWORD_FILE
            ${pkgs.prometheus-restic-exporter}/bin/restic-exporter.py
          '';
          environment = {
            LISTEN_ADDRESS = "0.0.0.0";
            LISTEN_PORT = toString backup.exporter.port;
            REFRESH_INTERVAL = "60";
            RESTIC_CACHE_DIR = "$CACHE_DIRECTORY";
            RESTIC_REPOSITORY = backup.repository;
          };
          serviceConfig = {
            CacheDirectory = "restic-exporter";
            EnvironmentFile = backup.environmentFile;
            LoadCredential = [ "RESTIC_PASSWORD_FILE:${backup.passwordFile}" ];
          };
        };
      }) config.services.restic.backups);
  };
}
