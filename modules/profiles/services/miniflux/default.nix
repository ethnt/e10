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

  networking.firewall = { allowedTCPPorts = [ 8070 ]; };
}
