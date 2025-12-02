{ config, hosts, ... }: {
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
}
