{ config, lib, profiles, suites, hosts, ... }: {
  imports = with suites;
    core ++ web ++ aws ++ [
      profiles.monitoring.loki
      profiles.monitoring.prometheus
      profiles.monitoring.rsyslogd
      profiles.monitoring.thanos.default
      profiles.observability.grafana.default
      profiles.telemetry.prometheus-pve-exporter.default
      profiles.telemetry.prometheus-redis-exporter
    ];

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

  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "host_router";
        static_configs = [{ targets = [ "router:9100" ]; }];
      }
      {
        job_name = "host_anise";
        static_configs = [{ targets = [ "anise:9100" ]; }];
      }
      {
        job_name = "host_basil";
        static_configs = [{ targets = [ "basil:9100" ]; }];
      }
      {
        job_name = "host_cardamom";
        static_configs = [{ targets = [ "cardamom:9100" ]; }];
      }
      {
        job_name = "host_satan";
        static_configs = [{ targets = [ "satan:9100" ]; }];
      }
      {
        job_name = "host_elderflower";
        static_configs = [{ targets = [ "elderflower:9100" ]; }];
      }
      {
        job_name = "node_builder";
        static_configs = [{
          targets = [
            "${hosts.builder.config.networking.hostName}:${
              toString
              hosts.builder.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "blocky";
        static_configs = [{
          targets = [
            "${hosts.controller.config.networking.hostName}:${
              toString
              hosts.controller.config.services.blocky.settings.ports.http
            }"
          ];
        }];
      }
      {
        job_name = "node_gateway";
        static_configs = [{
          targets = [
            "${hosts.gateway.config.networking.hostName}:${
              toString
              hosts.gateway.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "node_controller";
        static_configs = [{
          targets = [
            "${hosts.controller.config.networking.hostName}:${
              toString
              hosts.controller.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "node_monitor";
        static_configs = [{
          targets = [
            "${hosts.monitor.config.networking.hostName}:${
              toString
              hosts.monitor.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "node_omnibus";
        static_configs = [{
          targets = [
            "${hosts.omnibus.config.networking.hostName}:${
              toString
              hosts.omnibus.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "node_htpc";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString hosts.htpc.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "node_matrix";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.networking.hostName}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "host_satellite";
        static_configs = [{
          targets = [
            "${hosts.satellite.config.networking.hostName}:${
              toString
              hosts.satellite.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "host_dill";
        static_configs = [{
          targets = [
            "${hosts.dill.config.networking.hostName}:${
              toString hosts.dill.config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "smartctl_omnibus";
        static_configs = [{
          targets = [
            "${hosts.omnibus.config.networking.hostName}:${
              toString
              hosts.omnibus.config.services.prometheus.exporters.smartctl.port
            }"
          ];
        }];
      }
      {
        job_name = "zfs_omnibus";
        static_configs = [{
          targets = [
            "${hosts.omnibus.config.networking.hostName}:${
              toString
              hosts.omnibus.config.services.prometheus.exporters.zfs.port
            }"
          ];
        }];
      }
      {
        job_name = "nut_matrix";
        metrics_path = "/ups_metrics";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.networking.hostName}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.nut.port
            }"
          ];
        }];
      }
      {
        job_name = "nut_controller";
        metrics_path = "/ups_metrics";
        static_configs = [{
          targets = [
            "${hosts.controller.config.networking.hostName}:${
              toString
              hosts.controller.config.services.prometheus.exporters.nut.port
            }"
          ];
        }];
      }
      {
        job_name = "nut_satellite";
        metrics_path = "/ups_metrics";
        static_configs = [{
          targets = [
            "${hosts.satellite.config.networking.hostName}:${
              toString
              hosts.satellite.config.services.prometheus.exporters.nut.port
            }"
          ];
        }];
      }
      {
        job_name = "smokeping_controller";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.controller.config.networking.hostName}:${
              toString
              hosts.controller.config.services.prometheus.exporters.smokeping.port
            }"
          ];
        }];
        scrape_interval = "5s";
      }
      {
        job_name = "smokeping_satellite";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.satellite.config.networking.hostName}:${
              toString
              hosts.satellite.config.services.prometheus.exporters.smokeping.port
            }"
          ];
        }];
        scrape_interval = "5s";
      }
      {
        job_name = "satan_controller";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.controller.config.networking.hostName}:${
              toString
              hosts.controller.config.services.prometheus.exporters.unpoller.port
            }"
          ];
        }];
      }
      {
        job_name = "lawsonnet_controller";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.satellite.config.networking.hostName}:${
              toString
              hosts.satellite.config.services.prometheus.exporters.unpoller.port
            }"
          ];
        }];
      }
      {
        job_name = "sonarr";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.exportarr-sonarr.port
            }"
          ];
        }];
      }
      {
        job_name = "radarr";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.exportarr-radarr.port
            }"
          ];
        }];
      }
      {
        job_name = "bazarr";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.exportarr-bazarr.port
            }"
          ];
        }];
      }
      {
        job_name = "prowlarr";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.exportarr-prowlarr.port
            }"
          ];
        }];
      }
      {
        job_name = "plex";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.plex-media-server.port
            }"
          ];
        }];
      }
      {
        job_name = "sabnzbd";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.htpc.config.networking.hostName}:${
              toString
              hosts.htpc.config.services.prometheus.exporters.exportarr-sabnzbd.port
            }"
          ];
        }];
      }
      {
        job_name = "nginx_gateway";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.gateway.config.networking.hostName}:${
              toString
              hosts.gateway.config.services.prometheus.exporters.nginx.port
            }"
          ];
        }];
      }
      {
        job_name = "nginx_monitor";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.monitor.config.networking.hostName}:${
              toString
              hosts.monitor.config.services.prometheus.exporters.nginx.port
            }"
          ];
        }];
      }
      {
        job_name = "nginx_matrix";
        metrics_path = "/metrics";
        static_configs = [{
          targets = [
            "${hosts.matrix.config.networking.hostName}:${
              toString
              hosts.matrix.config.services.prometheus.exporters.nginx.port
            }"
          ];
        }];
      }
      {
        job_name = "pve";
        metrics_path = "/pve";
        static_configs =
          [{ targets = [ "anise" "basil" "cardamom" "elderflower" ]; }];
        params = {
          module = [ "default" ];
          node = [ "anise" "basil" "cardamom" "elderflower" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "${hosts.monitor.config.networking.hostName}:${
                toString
                hosts.monitor.config.services.prometheus.exporters.pve.port
              }";
          }
        ];
      }
      {
        job_name = "redis";
        metrics_path = "/scrape";
        static_configs = [{ targets = [ "redis://controller:6379" ]; }];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "${hosts.monitor.config.networking.hostName}:${
                toString
                hosts.monitor.config.services.prometheus.exporters.redis.port
              }";
          }
        ];
      }
    ];
  };

  e10.services.backup.jobs.system.exclude =
    lib.mkAfter [ "/var/lib/loki/wal" "/var/lib/prometheus2/data/wal" ];

  system.stateVersion = "23.11";
}
