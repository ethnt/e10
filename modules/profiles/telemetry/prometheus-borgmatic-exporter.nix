{ lib, ... }: {
  services.prometheus.exporters.borgmatic = {
    enable = true;
    openFirewall = true;

    configFile = "/etc/borgmatic.d/";
  };

  systemd.services.prometheus-borgmatic-exporter.serviceConfig = {
    User = lib.mkForce "borgmatic";
    Group = lib.mkForce "borgmatic";
  };
}
