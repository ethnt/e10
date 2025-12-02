let
  # Toggle for turning all endpoints off for maintenance
  maintenance = false;
in { config, lib, ... }: {
  imports = [ ./postgresql.nix ];

  sops = {
    secrets = {
      gatus_authelia_basic_auth.sopsFile = ./secrets.json;
      gatus_ntfy_token.sopsFile = ./secrets.json;
    };

    templates.gatus_environment_file = {
      content = ''
        GATUS_LOG_LEVEL=warn

        AUTHELIA_BASIC_AUTH=${config.sops.placeholder.gatus_authelia_basic_auth}
        NTFY_TOKEN=${config.sops.placeholder.gatus_ntfy_token}
      '';
      mode = "0660";
      restartUnits = [ "gatus.service" ];
    };
  };

  services.gatus = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.templates.gatus_environment_file.path;
    settings = {
      metrics = true;
      storage = {
        type = "postgres";
        path = "postgresql:///gatus?host=/run/postgresql";
        maximum-number-of-results = 1000;
        maximum-number-of-events = 1000;
      };
      ui = {
        title = "E10 - Status";
        description = "Status of E10 services";
        header = "E10";
        logo = "https://e10.land/favicon.ico";
        default-sort-by = "group";
      };
      alerting.ntfy = {
        topic = "status-alerts";
        url = "https://ntfy.e10.camp/";
        token = "$NTFY_TOKEN";
      };
      connectivity.checker = {
        target = "1.1.1.1:53";
        interval = "30s";
      };
      endpoints = let
        mkEndpoint = { name, url, group, interval ? "60s"
          , conditions ? [ "[STATUS] == 200" ], protected ? false
          , extraConfig ? { } }:
          ({
            inherit name url group interval conditions;
            enabled = !maintenance;
            alerts = [{
              enabled = true;
              type = "ntfy";
              description = "healthcheck failed";
              send-on-resolved = true;
            }];
          } // extraConfig // lib.optionalAttrs protected {
            headers = { Authorization = "Basic $AUTHELIA_BASIC_AUTH"; };
          });
        bastion = [
          (mkEndpoint {
            name = "Caddy";
            url = "http://bastion:2019/config";
            group = "Bastion";
          })
          (mkEndpoint {
            name = "Authelia";
            url = "https://auth.e10.camp";
            group = "Bastion";
          })
          (mkEndpoint {
            name = "LLDAP";
            url = "https://ldap.e10.camp";
            group = "Bastion";
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://bastion:9100";
            group = "Bastion";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://bastion:9996";
            group = "Bastion";
          })
        ];
        omnibus = [
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://omnibus:9100";
            group = "Omnibus";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://omnibus:9996";
            group = "Omnibus";
          })
          (mkEndpoint {
            name = "Prometheus SMART Exporter";
            url = "http://omnibus:9633";
            group = "Omnibus";
          })
          (mkEndpoint {
            name = "Prometheus ZFS Exporter";
            url = "http://omnibus:9134";
            group = "Omnibus";
          })
          (mkEndpoint {
            name = "NFS";
            url = "tcp://omnibus:111";
            group = "Omnibus";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "Samba";
            url = "tcp://omnibus:445";
            group = "Omnibus";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "Attic";
            url = "https://cache.e10.camp";
            group = "Omnibus";
          })
        ];
        htpc = [
          (mkEndpoint {
            name = "Plex";
            url = "https://e10.video/web/index.html";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Sonarr";
            url = "https://sonarr.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Radarr";
            url = "https://radarr.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Prowlarr";
            url = "https://prowlarr.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Profilarr";
            url = "https://profilarr.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Huntarr";
            url = "https://huntarr.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Tautulli";
            url = "https://tautulli.e10.video";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Wizarr";
            url = "https://join.e10.video";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Bazarr";
            url = "https://bazarr.e10.camp";
            group = "HTPC";
            protected = true;
          })
          (mkEndpoint {
            name = "SABnzbd";
            url = "https://sabnzbd.e10.camp";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Jellyseerr";
            url = "https://requests.e10.video";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Prometheus DCGM Exporter";
            url = "http://htpc:9400";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Prometheus Plex Exporter";
            url = "http://htpc:9594";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://htpc:9100";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://htpc:9996";
            group = "HTPC";
          })
          (mkEndpoint {
            name = "FileFlows";
            url = "https://fileflows.e10.camp";
            group = "HTPC";
            protected = true;
          })
        ];
        matrix = [
          (mkEndpoint {
            name = "e10.land";
            url = "https://e10.land";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://matrix:9100";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://matrix:9996";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Netbox";
            url = "https://netbox.e10.camp";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Immich";
            url = "https://immich.e10.camp";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "CUPS";
            url = "http://matrix:631";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Mazanoke";
            url = "https://mazanoke.e10.camp";
            group = "Matrix";
            protected = true;
          })
          (mkEndpoint {
            name = "Miniflux";
            url = "https://feeds.e10.camp";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Paperless";
            url = "https://paperless.e10.camp";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Stirling PDF";
            url = "https://pdf.e10.camp";
            group = "Matrix";
            protected = true;
          })
          (mkEndpoint {
            name = "Prometheus NUT Exporter";
            url = "http://matrix:9199";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Caddy";
            url = "http://matrix:2019/config";
            group = "Matrix";
          })
          (mkEndpoint {
            name = "Glance";
            url = "https://glance.e10.camp";
            group = "Matrix";
            protected = true;
          })
        ];
        builder = [
          (mkEndpoint {
            name = "nix-serve";
            url = "https://cache.builder.e10.camp";
            group = "Builder";
            conditions = [ "[STATUS] == 404" ];
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://builder:9100";
            group = "Builder";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://builder:9996";
            group = "Builder";
          })
        ];
        controller = [
          (mkEndpoint {
            name = "Blocky (DNS)";
            url = "tcp://controller:53";
            group = "Controller";
            interval = "30s";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "Blocky (API)";
            url = "http://controller:4022/api/blocking/status";
            group = "Controller";
            interval = "30s";
            conditions = [ "[STATUS] == 200" "[BODY].enabled == true" ];
          })
          (mkEndpoint {
            name = "UniFi Controller";
            url = "https://controller:8443";
            group = "Controller";
            extraConfig.client.insecure = true;
          })
          (mkEndpoint {
            name = "Speedtest Tracker";
            url = "https://speedtest-tracker.e10.camp";
            group = "Controller";
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://controller:9100";
            group = "Controller";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://controller:9996";
            group = "Controller";
          })
          (mkEndpoint {
            name = "Prometheus NUT Exporter";
            url = "http://controller:9199";
            group = "Controller";
          })
          (mkEndpoint {
            name = "Prometheus Smokeping Exporter";
            url = "http://controller:9199";
            group = "Controller";
          })
          (mkEndpoint {
            name = "Prometheus Unpoller Exporter";
            url = "http://controller:9130";
            group = "Controller";
          })

        ];
        monitor = [
          (mkEndpoint {
            name = "Authelia";
            url = "https://auth.monitor.e10.camp";
            group = "Monitor";
          })
          (mkEndpoint {
            name = "Caddy";
            url = "http://monitor:2019/config";
            group = "Monitor";
          })
          (mkEndpoint {
            name = "Grafana";
            url = "https://grafana.e10.camp";
            group = "Monitor";
          })
          (mkEndpoint {
            name = "Loki";
            url = "tcp://monitor:3100";
            group = "Monitor";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "Prometheus";
            url = "tcp://monitor:9090";
            group = "Monitor";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "rsyslogd";
            url = "tcp://monitor:514";
            group = "Monitor";
            conditions = [ "[CONNECTED] == true" ];
          })
          (mkEndpoint {
            name = "Prometheus Node Exporter";
            url = "http://monitor:9100";
            group = "Monitor";
          })
          (mkEndpoint {
            name = "Prometheus Borgmatic Exporter";
            url = "http://monitor:9996";
            group = "Monitor";
          })
        ];
        pikvm = [
          (mkEndpoint {
            name = "PiKVM";
            url = "https://pikvm";
            group = "PiKVM";
            extraConfig.client.insecure = true;
          })
        ];
      in bastion ++ omnibus ++ htpc ++ matrix ++ builder ++ controller
      ++ monitor ++ pikvm;
    };
  };
}
