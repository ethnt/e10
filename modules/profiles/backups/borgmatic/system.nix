{ config, profiles, ... }: {
  imports = [ ./common.nix profiles.filesystems.files.backup ];

  services.borgmatic.configurations.system = {
    source_directories = [ "/etc" "/var/lib" "/srv" "/root" ];
    exclude_patterns = [
      "**/.cache"
      "**/.nix-profile"
      "/var/lib/containers"
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/postgresql"
      "/var/lib/systemd"
      "/var/logs"
    ];
    repositories = [
      {
        label = "rsync.net";
        path =
          "ssh://de2228@de2228.rsync.net/./${config.networking.hostName}-system";
      }
      {
        label = "omnibus";
        path = "/mnt/files/backup/${config.networking.hostName}-system";
      }
    ];
    keep_daily = 3;
    keep_weekly = 2;
    keep_monthly = 2;
  };
}
