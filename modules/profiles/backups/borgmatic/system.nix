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
    repositories = let repositoryName = "${config.networking.hostName}-system";
    in [
      {
        label = "rsync.net";
        path = "ssh://de2228@de2228.rsync.net/./${repositoryName}";
      }
      {
        label = "omnibus";
        path = "/mnt/files/backup/${repositoryName}";
      }
    ];
    keep_daily = 3;
    keep_weekly = 2;
    keep_monthly = 2;
  };
}
