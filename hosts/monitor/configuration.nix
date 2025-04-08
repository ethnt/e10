{ config, profiles, suites, hosts, ... }: {
  imports = with suites;
    core ++ aws ++ web ++ [
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      profiles.telemetry.prometheus-redis-exporter
      profiles.services.uptime-kuma
    ] ++ [ ./profiles/prometheus.nix ./profiles/grafana/default.nix ];

  deployment.tags = [ "@external" ];

  services.caddy = {
    proxies = {
      "grafana.e10.camp" = {
        host = hosts.monitor;
        port = config.services.grafana.settings.server.http_port;
      };

      "status.e10.camp" = {
        host = hosts.monitor;
        port = config.services.uptime-kuma.settings.PORT;
      };

      "status.e10.video" = {
        host = hosts.monitor;
        port = config.services.uptime-kuma.settings.PORT;
      };
    };
  };

  system.stateVersion = "24.05";
}
