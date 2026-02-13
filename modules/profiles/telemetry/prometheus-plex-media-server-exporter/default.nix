{ config, ... }: {
  sops = {
    secrets.plex_token = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    templates."prometheus-plex-media-server-exporter/secrets" = {
      content = ''
        PLEX_TOKEN=${config.sops.placeholder.plex_token}
      '';
    };
  };

  services.prometheus.exporters.plex-media-server = {
    enable = true;
    url = "https://e10.video";
    secretsFile =
      config.sops.templates."prometheus-plex-media-server-exporter/secrets".path;
    openFirewall = true;
  };
}
