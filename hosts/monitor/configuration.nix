{ profiles, suites, ... }: {
  imports =
    with suites;
    core
    ++ hcloud
    ++ web
    ++ [
      profiles.communications.grafana-to-ntfy.default
      profiles.communications.ntfy.default
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.telemetry.vector.syslog
      profiles.monitoring.healthchecks.default
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
      ./profiles/gatus.nix
      ./profiles/prometheus.nix
      ./profiles/prometheus-ping-exporter.nix
      ./profiles/grafana/default.nix
      ./profiles/healthchecks/default.nix
    ]
    ++ [
      ./disk-config.nix
      ./hardware-configuration.nix
    ];

  deployment = {
    vmType = "hcloud";
    tags = [ "@external" ];
  };

  services.loki.configuration = {
    common.ring.instance_interface_names = [ "enp1s0" ];
    ingester.lifecycler.interface_names = [ "enp1s0" ];
  };

  system.stateVersion = "24.05";
}
