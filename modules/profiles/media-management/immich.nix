{ config, ... }: {
  services.immich = {
    enable = true;
    openFirewall = true;
    redis.enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/files/services/immich";
    environment.TZ = "America/New_York";
  };

  systemd.tmpfiles.rules = [
    "d '${config.services.immich.mediaLocation}' 0777 ${config.services.immich.user} ${config.services.immich.group} - -"
  ];
}
