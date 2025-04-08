{ config, pkgs, ... }: {
  sops.secrets = {
    netbox_secret_key = {
      sopsFile = ./secrets.json;
      owner = "netbox";
    };
  };

  services.postgresqlBackup.databases = [ "netbox" ];

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    settings = {
      CSRF_TRUSTED_ORIGINS = [
        "https://netbox.e10.camp"
        "http://${config.networking.hostName}:${
          toString config.services.netbox.port
        }"
        "http://${config.networking.hostName}:8002"
      ];
    };
    secretKeyFile = config.sops.secrets.netbox_secret_key.path;
    listenAddress = "0.0.0.0";
  };

  services.caddy.virtualHosts."http://netbox.e10.camp:8002" = {
    extraConfig = ''
      encode gzip zstd

      root * ${config.services.netbox.dataDir}

      @proxied {
        not path /static/*
      }

      reverse_proxy @proxied http://localhost:${
        toString config.services.netbox.port
      }

      file_server
    '';
  };

  # Needed so Caddy can read Netbox's static files
  users.groups.netbox.members = [ config.services.caddy.user ];

  networking.firewall.allowedTCPPorts = [ config.services.netbox.port 8002 ];
}
