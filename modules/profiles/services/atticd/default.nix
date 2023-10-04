{ config, ... }:
let storagePath = "/data/files/services/atticd/storage";
in {
  sops.secrets = {
    attic_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  systemd.tmpfiles.rules = [
    "d '${storagePath}' 0777 ${config.services.atticd.user} ${config.services.atticd.group} - -"
  ];

  services.atticd = {
    enable = true;
    credentialsFile = config.sops.secrets.attic_credentials.path;
    settings = {
      listen = "[::]:8080";

      # Do not change this! Otherwise caches need to be recreated!
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };

      database.url = "postgres://atticd?host=/run/postgresql";

      storage = {
        type = "local";
        path = storagePath;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
