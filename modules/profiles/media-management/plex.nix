{ config, lib, ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/plex/transcode' 0777 ${config.services.plex.user} ${config.services.plex.group} - -"
  ];

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/plex/Plex Media Server/Cache" ];
}
