{ config, inputs, ... }: {
  imports = [ inputs.attic.nixosModules.atticd ];

  sops.secrets = {
    attic_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.atticd = {
    enable = true;
    credentialsFile = config.sops.secrets.attic_credentials.path;
    settings = {
      listen = "[::]:8080";

      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };

      database.url = "postgres://atticd?host=/run/postgresql";

      storage = {
        type = "local";
        path = "/data/files/services/atticd/storage";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
