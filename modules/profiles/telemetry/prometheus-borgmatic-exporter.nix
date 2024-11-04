{ lib, ... }: {
  services.prometheus.exporters.borgmatic = {
    enable = true;
    openFirewall = true;

    # TODO: Monitor all configuration files
    configFile = "/etc/borgmatic.d/system.yaml";
  };

  systemd.services.prometheus-borgmatic-exporter.serviceConfig = {
    User = lib.mkForce "borgmatic";
    Group = lib.mkForce "borgmatic";
  };
}
