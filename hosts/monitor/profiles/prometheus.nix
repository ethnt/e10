{
  profiles,
  hosts,
  lib,
  ...
}:
{
  imports = [ profiles.monitoring.prometheus ];

  services.prometheus.scrapeConfigs = [
    {
      job_name = "blocky";
      static_configs = [
        {
          targets = [
            "${hosts.controller.config.networking.hostName}:${toString hosts.controller.config.services.blocky.settings.ports.http}"
          ];
        }
      ];
    }
    {
      job_name = "node";
      static_configs = [
        {
          targets = [
            "${hosts.matrix.config.networking.hostName}:${toString hosts.matrix.config.services.prometheus.exporters.node.port}"
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.node.port}"
            "${hosts.omnibus.config.networking.hostName}:${toString hosts.omnibus.config.services.prometheus.exporters.node.port}"
            "${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.prometheus.exporters.node.port}"
            "${hosts.controller.config.networking.hostName}:${toString hosts.controller.config.services.prometheus.exporters.node.port}"
            "${hosts.bastion.config.networking.hostName}:${toString hosts.bastion.config.services.prometheus.exporters.node.port}"
            "${hosts.builder.config.networking.hostName}:${toString hosts.builder.config.services.prometheus.exporters.node.port}"
            "router:9100"
            "anise:9100"
            "basil:9100"
            "cardamom:9100"
            "dill:9100"
            "satan:9100"
            "elderflower:9100"
            "pikvm:9100"
          ];
        }
      ];
    }
    {
      job_name = "smartctl";
      static_configs = [
        {
          targets = [
            "${hosts.omnibus.config.networking.hostName}:${toString hosts.omnibus.config.services.prometheus.exporters.smartctl.port}"
          ];
        }
      ];
    }
    {
      job_name = "zfs";
      static_configs = [
        {
          targets = [
            "${hosts.omnibus.config.networking.hostName}:${toString hosts.omnibus.config.services.prometheus.exporters.zfs.port}"
          ];
        }
      ];
    }
    {
      job_name = "nut";
      metrics_path = "/ups_metrics";
      static_configs = [
        {
          targets = [
            "${hosts.controller.config.networking.hostName}:${toString hosts.controller.config.services.prometheus.exporters.nut.port}"
            "${hosts.matrix.config.networking.hostName}:${toString hosts.matrix.config.services.prometheus.exporters.nut.port}"
          ];
        }
      ];
    }
    {
      job_name = "smokeping";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.controller.config.networking.hostName}:${toString hosts.controller.config.services.prometheus.exporters.smokeping.port}"
          ];
        }
      ];
      scrape_interval = "5s";
    }
    {
      job_name = "unifi";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.controller.config.networking.hostName}:9130"
          ];
        }
      ];
    }
    {
      job_name = "sonarr";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.exportarr-sonarr.port}"
          ];
        }
      ];
    }
    {
      job_name = "radarr";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.exportarr-radarr.port}"
          ];
        }
      ];
    }
    {
      job_name = "bazarr";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.exportarr-bazarr.port}"
          ];
        }
      ];
    }
    {
      job_name = "prowlarr";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.exportarr-prowlarr.port}"
          ];
        }
      ];
    }
    {
      job_name = "plex";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.plex-exporter.port}"
          ];
        }
      ];
    }
    {
      job_name = "sabnzbd";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.exportarr-sabnzbd.port}"
          ];
        }
      ];
    }
    {
      job_name = "authelia";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.bastion.config.networking.hostName}:9959"
            "${hosts.monitor.config.networking.hostName}:9959"
          ];
        }
      ];
    }
    {
      job_name = "caddy";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.matrix.config.networking.hostName}:2019"
            "${hosts.monitor.config.networking.hostName}:2019"
            "${hosts.bastion.config.networking.hostName}:2019"
          ];
        }
      ];
    }
    {
      job_name = "pve";
      metrics_path = "/pve";
      static_configs = [
        {
          targets = [
            "anise"
            "basil"
            "cardamom"
            "elderflower"
          ];
        }
      ];
      params = {
        module = [ "default" ];
        node = [
          "anise"
          "basil"
          "cardamom"
          "elderflower"
        ];
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
          replacement = "${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.prometheus.exporters.pve.port}";
        }
      ];
    }
    {
      job_name = "redis";
      metrics_path = "/scrape";
      static_configs = [ { targets = [ "redis://controller:6379" ]; } ];
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
          replacement = "${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.prometheus.exporters.redis.port}";
        }
      ];
    }
    {
      job_name = "gpu";
      static_configs = [
        {
          targets = [
            "${hosts.htpc.config.networking.hostName}:${toString hosts.htpc.config.services.prometheus.exporters.dcgm-exporter.port}"
          ];
        }
      ];
    }
    {
      job_name = "gatus";
      static_configs = [
        {
          targets = [
            "${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.gatus.settings.web.port}"
          ];
        }
      ];
      scrape_interval = "30s";
    }
    {
      job_name = "frigate";
      metrics_path = "/api/metrics";
      static_configs = [ { targets = [ "htpc:5000" ]; } ];
      scrape_interval = "15s";
    }
    {
      job_name = "speedtest-tracker";
      metrics_path = "/prometheus";
      static_configs = [ { targets = [ "speedtest-tracker.e10.camp" ]; } ];
      scrape_interval = "45m";
    }
    {
      job_name = "ping";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [
            "${hosts.controller.config.networking.hostName}:${toString hosts.controller.config.services.prometheus.exporters.ping.port}"
            "${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.prometheus.exporters.ping.port}"
          ];
        }
      ];
      scrape_interval = "5s";
    }
    {
      job_name = "jetkvm";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [ "elderflower-kvm:80" ];
        }
      ];
    }
    {
      job_name = "pikvm";
      metrics_path = "/api/export/prometheus/metrics";
      static_configs = [
        {
          targets = [ "pikvm:80" ];
        }
      ];
      tls_config = {
        insecure_skip_verify = true;
      };
    }
  ]
  ++ lib.pipe hosts [
    (lib.mapAttrsToList (
      _: host:
      lib.pipe host.config.services.restic.backups [
        (lib.mapAttrsToList (
          name: backup:
          lib.optional backup.exporter.enable {
            job_name = "restic_${host.config.networking.hostName}_${
              builtins.replaceStrings [ "-" ] [ "_" ] name
            }";
            metrics_path = "/";
            scrape_interval = "5m";
            static_configs = [
              {
                targets = [
                  "${host.config.networking.hostName}:${toString backup.exporter.port}"
                ];
              }
            ];
          }
        ))
        lib.flatten
      ]
    ))
    lib.flatten
  ];
}
