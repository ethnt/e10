{ config, lib, ... }: {
  imports = [ ./common.nix ];

  services.restic.backups = let
    sharedOptions = {
      initialize = true;
      passwordFile = config.sops.secrets.restic_backup_password.path;
      paths = [ "/etc" "/var/lib" "/srv" "/root" ];
      exclude = [
        "**/.cache"
        "**/.nix-profile"
        "**/*.log"
        "/var/lib/containers"
        "/var/lib/docker"
        "/var/lib/libvirt"
        "/var/lib/postgresql"
        "/var/lib/private"
        "/var/lib/systemd"
        "/var/logs"
      ];
      timerConfig = {
        OnCalendar = "03:30";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      pruneOpts = [ "--keep-daily 3" "--keep-weekly 2" "--keep-monthly 2" ];
      exporter.enable = true;
    };
  in {
    system-omnibus = lib.recursiveUpdate {
      repository =
        "rest:http://omnibus:8000/${config.networking.hostName}/system";
      environmentFile =
        config.sops.templates.omnibus_rest_server_environment_file.path;
      exporter.port = 9753;
    } sharedOptions;

    system-rsync-net = lib.recursiveUpdate {
      repository =
        "sftp://de2228@de2228.rsync.net/${config.networking.hostName}/system";
      extraOptions =
        [ "sftp.args='-i ${config.sops.secrets.rsync_net_ssh_key.path}'" ];
      exporter = {
        enable = true;
        port = 9754;
      };
    } sharedOptions;
  };
}
