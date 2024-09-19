{ config, inputs, profiles, ... }:
let storagePath = "/data/files/services/atticd/storage";
in {
  imports =
    [ inputs.attic.nixosModules.atticd profiles.databases.postgresql.atticd ];

  sops.secrets = {
    atticd_credentials_file = {
      format = "yaml";
      sopsFile = ./secrets.yml;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${storagePath} 0777 ${config.services.atticd.user} ${config.services.atticd.group}"
  ];

  services.atticd = {
    enable = true;

    credentialsFile = config.sops.secrets.atticd_credentials_file.path;

    settings = {
      allowed-hosts = [ ];
      listen = "[::]:8080";
      require-proof-of-possession = true;

      database.url = "postgresql:///atticd?host=/run/postgresql";

      api-endpoint = "https://cache.e10.camp/";

      storage = {
        type = "local";
        path = storagePath;
      };

      # Data chunking
      # <https://docs.attic.rs/admin-guide/deployment/nixos.html>
      # <https://docs.attic.rs/admin-guide/chunking.html>
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
