{ config, ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/plex/transcode' 0777 ${config.services.plex.user} ${config.services.plex.group} - -"
  ];
}
