{ config, pkgs, hosts, ... }: {
  services.grafana = {
    enable = true;

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
      grafana-clock-panel
    ];

    settings = {
      server = {
        domain = "localhost";
        http_port = 2342;
        http_addr = "127.0.0.1";
      };

      panels = {
        enable_alpha = "true";
        disable_sanitize_html = "true";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://0.0.0.0:${toString config.services.prometheus.port}";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://0.0.0.0:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }";
        }
        {
          name = "PostgreSQL (Blocky)";
          type = "postgres";
          access = "proxy";
          url = hosts.controller.config.networking.hostName;
          user = "blocky";
          jsonData = {
            user = "blocky";
            database = "blocky";
            sslmode = "disable";
          };
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Nodes";
          options.path = ./provisioning/nodes.json;
        }
        {
          name = "systemd Service Dashboard";
          options.path = ./provisioning/systemd.json;
        }
        {
          name = "UPS Status";
          options.path = ./provisioning/nut.json;
        }
        {
          name = "ZFS Pool Status";
          options.path = ./provisioning/zfs.json;
        }
        {
          name = "Blocky Metrics";
          options.path = ./provisioning/blocky.json;
        }
        {
          name = "Blocky Queries";
          options.path = ./provisioning/blocky-queries.json;
        }
        {
          name = "Smokeping";
          options.path = ./provisioning/smokeping.json;
        }
        {
          name = "Unifi: Client Insights";
          options.path = ./provisioning/unifi/clients.json;
        }
        {
          name = "Unifi: Switch Insights";
          options.path = ./provisioning/unifi/switches.json;
        }
        {
          name = "Unifi: AP Insights";
          options.path = ./provisioning/unifi/aps.json;
        }
        {
          name = "Unifi: Network Site Insights";
          options.path = ./provisioning/unifi/sites.json;
        }
      ];
    };
  };
}
