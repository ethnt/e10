{ config, profiles, suites, ... }: {
  imports = with suites;
    core ++ web ++ aws ++ [
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      profiles.telemetry.prometheus-pve-exporter.default
      profiles.telemetry.prometheus-redis-exporter
    ] ++ [ ./profiles/prometheus.nix ./profiles/grafana/default.nix ];

  services.nginx.virtualHosts = {
    "grafana.e10.camp" = {
      http2 = true;
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass =
          "http://${config.services.grafana.settings.server.http_addr}:${
            toString config.services.grafana.settings.server.http_port
          }";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };
  };

  system.stateVersion = "23.11";
}
