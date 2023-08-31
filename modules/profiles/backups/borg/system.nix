{ config, pkgs, ... }: {
  e10.backup.jobs.system = {
    repoName = "${config.networking.hostName}-system";
    paths = [ "/etc" "/var/lib" "/srv" "/root" ];
    exclude = [
      "/var/lib/docker"
      "/var/lib/systemd"
      "/var/lib/libvirt"
      "'**/.cache'"
      "'**/.nix-profile'"
    ];
  };
}
