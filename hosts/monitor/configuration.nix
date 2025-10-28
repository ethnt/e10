{ config, profiles, suites, hosts, ... }: {
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
      ./profiles/prometheus.nix
      ./profiles/grafana/default.nix
    ];

  deployment.tags = [ "@external" ];

  services.caddy = {
    proxies = {
      "auth.monitor.e10.camp" = {
        host = hosts.monitor;
        port = 9091;
        extraConfig = ''
          header Access-Control-Allow-Origin "*"
        '';
      };

      "grafana.e10.camp" = {
        host = hosts.monitor;
        port = config.services.grafana.settings.server.http_port;
      };

      "status.e10.camp" = {
        host = hosts.monitor;
        inherit (config.services.gatus.settings.web) port;
        protected = true;
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
