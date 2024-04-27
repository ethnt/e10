{ config, hosts, ... }: {
  imports = [ ./common.nix ];

  services.prometheus.exporters.unpoller.controllers = [{
    url = "https://${hosts.controller.config.networking.hostName}:8443";
    user = "ethnt-unpoller";
    pass = config.sops.secrets.satan_unifi_password.path;
    verify_ssl = false;
  }];
}
