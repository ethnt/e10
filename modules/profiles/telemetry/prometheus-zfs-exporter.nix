{ config, ... }: {
  services.prometheus.exporters.zfs = {
    enable = true;
    openFirewall = true;
  };

  provides.prometheus-zfs-exporter = {
    name = "Prometheus ZFS Exporter";
    http = { inherit (config.services.prometheus.exporters.zfs) port; };
    monitor.enable = true;
  };
}
