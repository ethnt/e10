{ config, ... }: {
  e10.services.backup.jobs.system = {
    repoName = "${config.networking.hostName}-system";
    paths = [ "/etc" "/var/lib" "/srv" "/root" ];
    exclude = [
      "/var/lib/docker"
      "/var/lib/systemd"
      "/var/lib/libvirt"
      "/var/logs"
      "'**/.cache'"
      "'**/.nix-profile'"
    ];
  };
}
