{ config, ... }: {
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/sabnzbd/inter' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    "d '/data/local/tmp/sabnzbd/dst' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
  ];
}
