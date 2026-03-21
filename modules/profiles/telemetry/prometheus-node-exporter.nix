{ config, ... }: {
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    enabledCollectors = [ "systemd" ];
  };

  provides."prometheus-node-exporter-${config.networking.hostName}" = {
    name = "Prometheus Node Exporter";
    http = { port = 9100; };
    monitor = {
      enable = true;
      url = "http://${config.networking.hostName}:9100";
    };
  };
}
