{ config, profiles, suites, hosts, ... }: {
  imports = with suites;
    core ++ aws ++ web ++ [
      profiles.communications.grafana-to-ntfy.default
      profiles.communications.ntfy
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      profiles.observability.grafana
      profiles.services.uptime-kuma
      profiles.telemetry.prometheus-redis-exporter
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

      "ntfy.e10.camp" = {
        host = hosts.monitor;
        port = 2586;
        extraConfig = ''
          @httpget {
            protocol http
            method GET
            path_regexp ^/([-_a-z0-9]{0,64}$|docs/|static/)
          }

          redir @httpget https://{host}{uri}
        '';
      };
    };
  };

  system.stateVersion = "24.05";
}
