{ profiles, suites, ... }: {
  imports =
    with suites;
    core
    ++ aws
    ++ web
    ++ [
      profiles.communications.grafana-to-ntfy.default
      profiles.communications.ntfy.default
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.telemetry.vector.syslog
      profiles.monitoring.thanos.default
      profiles.observability.gatus.default
      profiles.observability.grafana
      profiles.observability.uptime-kuma
      profiles.telemetry.prometheus-ping-exporter
      profiles.telemetry.prometheus-redis-exporter
    ]
    ++ [
      ./profiles/authelia
      ./profiles/caddy.nix
      ./profiles/prometheus.nix
      ./profiles/prometheus-ping-exporter.nix
      ./profiles/grafana/default.nix
    ];

  deployment = {
    vmType = "aws-ec2";
    tags = [ "@external" ];
  };

  system.stateVersion = "24.05";
}
