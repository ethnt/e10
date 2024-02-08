{ config, hosts, ... }: {
  sops.secrets = {
    unifi_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = config.services.prometheus.exporters.unpoller.user;
      inherit (config.services.prometheus.exporters.unpoller) group;
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
