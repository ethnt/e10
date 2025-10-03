{ profiles, hosts, ... }: {
  imports = [ profiles.monitoring.prometheus ];

  services.prometheus.scrapeConfigs = [
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
            toString hosts.controller.config.services.blocky.settings.ports.http
          }"
        ];
      }];
    }
    {
      job_name = "node_bastion";
      static_configs = [{
        targets = [
          "${hosts.bastion.config.networking.hostName}:${
            toString
            hosts.bastion.config.services.prometheus.exporters.node.port
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
            toString hosts.matrix.config.services.prometheus.exporters.node.port
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
            toString hosts.omnibus.config.services.prometheus.exporters.zfs.port
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
            toString hosts.matrix.config.services.prometheus.exporters.nut.port
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
      job_name = "authelia_bastion";
      metrics_path = "/metrics";
      static_configs =
        [{ targets = [ "${hosts.bastion.config.networking.hostName}:9959" ]; }];
    }
    {
      job_name = "caddy_bastion";
      metrics_path = "/metrics";
      static_configs =
        [{ targets = [ "${hosts.bastion.config.networking.hostName}:2019" ]; }];
    }
    {
      job_name = "caddy_matrix";
      metrics_path = "/metrics";
      static_configs =
        [{ targets = [ "${hosts.matrix.config.networking.hostName}:2019" ]; }];
    }
    {
      job_name = "caddy_monitor";
      metrics_path = "/metrics";
      static_configs =
        [{ targets = [ "${hosts.monitor.config.networking.hostName}:2019" ]; }];
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
    {
      job_name = "htpc_gpu";
      static_configs = [{
        targets = [
          "${hosts.htpc.config.networking.hostName}:${
            toString
            hosts.htpc.config.services.prometheus.exporters.dcgm-exporter.port
          }"
        ];
      }];
    }
    {
      job_name = "borgmatic_builder";
      static_configs = [{
        targets = [
          "${hosts.builder.config.networking.hostName}:${
            toString
            hosts.builder.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "borgmatic_matrix";
      static_configs = [{
        targets = [
          "${hosts.matrix.config.networking.hostName}:${
            toString
            hosts.matrix.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "borgmatic_bastion";
      static_configs = [{
        targets = [
          "${hosts.bastion.config.networking.hostName}:${
            toString
            hosts.bastion.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "borgmatic_htpc";
      static_configs = [{
        targets = [
          "${hosts.htpc.config.networking.hostName}:${
            toString
            hosts.htpc.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "borgmatic_omnibus";
      scrape_timeout = "30s";
      static_configs = [{
        targets = [
          "${hosts.omnibus.config.networking.hostName}:${
            toString
            hosts.omnibus.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "borgmatic_controller";
      static_configs = [{
        targets = [
          "${hosts.controller.config.networking.hostName}:${
            toString
            hosts.controller.config.services.prometheus.exporters.borgmatic.port
          }"
        ];
      }];
      scrape_interval = "1m";
    }
    {
      job_name = "garage";
      static_configs =
        [{ targets = [ "${hosts.omnibus.config.networking.hostName}:3903" ]; }];
    }
  ];
}
