{ config, hosts, ... }: {
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

  services.prometheus.exporters.unpoller = {
    enable = true;

    loki = {
      url = "http://${hosts.monitor.config.networking.hostName}:${
          toString
          hosts.monitor.config.services.loki.configuration.server.http_listen_port
        }";
    };
  };
}
