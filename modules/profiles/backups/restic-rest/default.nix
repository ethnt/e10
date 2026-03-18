{ config, ... }: {
  sops.secrets.restic_rest_httpasswd_file = {
    sopsFile = ./secrets.yml;
    format = "yaml";
    owner = "restic";
  };

  systemd.tmpfiles.settings."10-restic-rest" = {
    ${config.services.restic.server.dataDir} = {
      "d" = {
        user = "restic";
        group = "restic";
        mode = "0777";
      };
    };
  };

  services.restic.server = {
    enable = true;
    dataDir = "/data/files/services/restic";
    htpasswd-file = config.sops.secrets.restic_rest_httpasswd_file.path;
    prometheus = true;
  };
}
