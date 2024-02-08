{ config, hosts, ... }: {
  sops.secrets = {
    unifi_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.prometheus.exporters.unpoller.user;
      group = config.services.prometheus.exporters.unpoller.group;
    };
  };

  services.prometheus.exporters.unpoller = {
    enable = true;
    controllers = [{
      url = "https://${hosts.controller.config.networking.hostName}:8443";
      user = "ethnt-unpoller";
      pass = config.sops.secrets.unifi_password.path;
      verify_ssl = false;
    }];
  };
}
