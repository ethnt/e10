{ lib, ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/plex/Plex Media Server/Cache" ];
}
