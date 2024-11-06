{ config, profiles, suites, ... }: {
  imports = with suites;
    core ++ web ++ aws ++ [
      profiles.monitoring.loki.default
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      # profiles.telemetry.prometheus-pve-exporter.default
      profiles.telemetry.prometheus-redis-exporter
      profiles.services.uptime-kuma
    ] ++ [ ./profiles/prometheus.nix ./profiles/grafana/default.nix ];

  deployment.tags = [ "@external" ];

  services.nginx.virtualHosts = {
    "status.e10.camp" = {
      http2 = true;
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${config.networking.hostName}:${
            toString config.services.uptime-kuma.settings.PORT
          }";
        proxyWebsockets = true;
      };
    };

    "grafana.e10.camp" = {
      http2 = true;
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${config.networking.hostName}:${
            toString config.services.grafana.settings.server.http_port
          }";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };

    "status.e10.video" = {
      http2 = true;
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${config.networking.hostName}:${
            toString config.services.uptime-kuma.settings.PORT
          }";
        proxyWebsockets = true;
      };
    };
  };

  system.stateVersion = "24.05";
}
