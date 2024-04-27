{ config, ... }: {
  sops.secrets = {
    satan_unifi_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.prometheus.exporters.unpoller.user;
      inherit (config.services.prometheus.exporters.unpoller) group;
    };

    lawsonnet_unifi_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.prometheus.exporters.unpoller.user;
      inherit (config.services.prometheus.exporters.unpoller) group;
    };
  };

  services.prometheus.exporters.unpoller.enable = true;
}
