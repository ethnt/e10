{ config, ... }: {
  imports = [ ./common.nix ];

  services.prometheus.exporters.unpoller.controllers = [{
    url = "https://192.168.1.1";
    user = "ethnt-unpoller";
    pass = config.sops.secrets.lawsonnet_unifi_password.path;
    verify_ssl = false;
    save_ids = true;
    save_events = true;
    save_anomalies = true;
    save_alarms = true;
  }];
}
