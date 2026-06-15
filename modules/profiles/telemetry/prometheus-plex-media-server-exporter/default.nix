{ config, ... }: {
  sops.secrets.plex_token = {
    sopsFile = ./secrets.yml;
    format = "yaml";
    mode = "0700";
    owner = config.services.prometheus.exporters.plex-media-server.user;
  };

  services.prometheus.exporters.plex-media-server = {
    enable = true;
    url = "https://e10.video";
    tokenFile = config.sops.secrets.plex_token.path;
    openFirewall = true;
  };
}
