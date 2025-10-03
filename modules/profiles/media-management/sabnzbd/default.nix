{ config, lib, ... }: {
  sops.secrets.sabnzbd_config_file = {
    format = "yaml";
    sopsFile = ./secrets.yml;
    owner = config.services.sabnzbd.user;
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    configFile = config.sops.secrets.sabnzbd_config_file.path;
  };

  systemd.services.sabnzbd.serviceConfig.ExecStart = lib.mkOverride 10 "${
      lib.getExe' config.services.sabnzbd.package "sabnzbd"
    } -d -f ${config.services.sabnzbd.configFile} --disable-file-log";

  systemd.tmpfiles.rules = [
    "d '/data/local/tmp/sabnzbd/inter' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
    "d '/data/local/tmp/sabnzbd/dst' 0777 ${config.services.sabnzbd.user} ${config.services.sabnzbd.group} - -"
  ];
}
