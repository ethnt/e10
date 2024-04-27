{ config, ... }: {
  sops.secrets.prometheus_plex_media_server_exporter_secrets = {
    sopsFile = ./secrets.yml;
    format = "yaml";
  };

  services.prometheus.exporters.plex-media-server = {
    enable = true;
    url = "https://e10.video";
    secretsFile =
      config.sops.secrets.prometheus_plex_media_server_exporter_secrets.path;
    openFirewall = true;
  };
}
