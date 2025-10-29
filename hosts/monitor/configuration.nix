{ profiles, suites, ... }: {
  imports = with suites;
    core ++ aws ++ web ++ [
      profiles.communications.grafana-to-ntfy.default
      profiles.communications.ntfy
      profiles.monitoring.loki.default
      profiles.monitoring.influxdb2.default
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      profiles.observability.gatus.default
      profiles.observability.grafana
      profiles.telemetry.prometheus-redis-exporter
    ] ++ [
      ./profiles/authelia
      ./profiles/caddy.nix
      ./profiles/prometheus.nix
      ./profiles/grafana/default.nix
    ];

  deployment.tags = [ "@external" ];

  system.stateVersion = "24.05";
}
