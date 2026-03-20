{ config, ... }: {
  sops.secrets = {
    miniflux_admin_credentials = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.miniflux = {
    enable = true;
    config = { PORT = "8070"; };
    adminCredentialsFile = config.sops.secrets.miniflux_admin_credentials.path;
  };

  services.postgresqlBackup.databases = [ "miniflux" ];

  networking.firewall = { allowedTCPPorts = [ 8070 ]; };

  provides.miniflux = {
    name = "Miniflux";
    http = {
      enable = true;
      port = config.services.miniflux.config.PORT;
      domain = "feeds.e10.camp";
    };
  };
}
