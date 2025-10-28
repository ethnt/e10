{ config, hosts, ... }: {
  sops.secrets = let
    sopsConfig = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "grafana";
    };
  in {
    grafana_to_ntfy_password = sopsConfig;
    grafana_smtp2go_username = sopsConfig;
    grafana_smtp2go_password = sopsConfig;
    grafana_influxdb2_grafana_token = sopsConfig;
    grafana_authelia_client_secret = sopsConfig;
  };

  services.grafana = {
    settings = {
      server = {
        domain = "grafana.e10.camp";
        root_url = "https://grafana.e10.camp";
      };

      "auth.generic_oauth" = {
        enabled = true;
        name = "Authelia";
        icon = "signin";
        client_id =
          "1vukV4u1uEh~p-HGYBHhB-xv.ZyyKW3tI2Cco5F1f_jaI9Qamn_oc4rLoy7nqx3h3IwnsB5.";
        client_secret =
          "$__file{${config.sops.secrets.grafana_authelia_client_secret.path}}";
        scopes = "openid profile email groups";
        empty_scopes = "false";
        auth_url = "https://auth.monitor.e10.camp/api/oidc/authorization";
        token_url = "https://auth.monitor.e10.camp/api/oidc/token";
        api_url = "https://auth.monitor.e10.camp/api/oidc/userinfo";
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        name_attribute_path = "name";
        use_pkce = "true";
        role_attribute_path =
          "contains(groups[*], 'admin') && 'Admin' || contains(groups[*], 'editor') && 'Editor' || 'Viewer'";
      };

      smtp = {
        enabled = true;
        host = "mail.smtp2go.com:2525";
        user = "$__file{${config.sops.secrets.grafana_smtp2go_username.path}}";
        password =
          "$__file{${config.sops.secrets.grafana_smtp2go_password.path}}";
        startTLS_policy = "MandatoryStartTLS";
        skip_verify = true;
        from_address = "monitor@e10.camp";
        from_name = "Grafana";
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        datasources = [
          {
            name = "Thanos";
            type = "prometheus";
            access = "proxy";
            url = "http://${hosts.monitor.config.networking.hostName}:${
                toString config.services.thanos.query.http.port
              }";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://${hosts.monitor.config.networking.hostName}:${
                toString
                config.services.loki.configuration.server.http_listen_port
              }";
          }
          {
            name = "PostgreSQL";
            type = "postgres";
            access = "proxy";
            url = hosts.controller.config.networking.hostName;
            user = "blocky";
            postgresVersion = 1500;
            jsonData = {
              user = "blocky";
              database = "blocky";
              sslmode = "disable";
            };
          }
          {
            name = "InfluxDB (Speedtest Tracker)";
            type = "influxdb";
            access = "proxy";
            url = "http://${hosts.monitor.config.networking.hostName}:8086";
            basicAuth = true;
            basicAuthUser = "admin";
            jsonData = {
              dbName = "speedtest-tracker";
              httpMode = "POST";
              tlsSkipVerify = true;
            };
            secureJsonData = {
              basicAuthPassword =
                "$__file{${hosts.monitor.config.sops.secrets.grafana_influxdb2_grafana_token.path}}";
            };
          }
        ];
      };
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
          name = "HTPC";
          options.path = ./provisioning/htpc.json;
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
        {
          name = "Proxmox";
          options.path = ./provisioning/proxmox.json;
        }
        {
          name = "Nvidia";
          options.path = ./provisioning/nvidia.json;
        }
        {
          name = "Borgmatic Logs";
          options.path = ./provisioning/borgmatic/logs.json;
        }
        {
          name = "Borgmatic Backups";
          options.path = ./provisioning/borgmatic/backups.json;
        }
        {
          name = "Caddy";
          options.path = ./provisioning/caddy.json;
        }
        {
          name = "Speedtest Tracker";
          options.path = ./provisioning/speedtest-tracker.json;
        }
        {
          name = "Gatus Service Monitoring";
          options.path = ./provisioning/gatus.json;
        }
      ];

      alerting = {
        contactPoints.settings = {
          apiVersion = 1;

          contactPoints = [
            {
              name = "Email";
              receivers = [{
                uid = "1";
                type = "email";
                settings = { addresses = "ethan+e10@turkeltaub.dev"; };
              }];
            }
            {
              name = "Ntfy";
              receivers = [{
                uid = "20";
                type = "webhook";
                settings = {
                  httpMethod = "POST";
                  url = "http://0.0.0.0:8000";
                  username = "admin";
                  password =
                    "$__file{${config.sops.secrets.grafana_to_ntfy_password.path}}";
                };
              }];
            }
          ];
        };

        policies.settings = {
          apiVersion = 1;

          policies = [{
            orgId = 1;
            receiver = "Email";
            group_by = [ "grafana_folder" "alertname" ];
            routes = [{
              receiver = "Ntfy";
              object_matchers = [[ "severity" "=" "critical" ]];
            }];
          }];
        };

        rules.settings = {
          apiVersion = 1;
          groups = [{
            orgId = 1;
            name = "Default";
            interval = "60s";
            folder = "Homelab";
            rules = [
              {
                uid = "a0513fe1-c679-4411-8512-d52334814942";
                title = "Rack UPS is on battery power";
                condition = "C";
                data = [
                  {
                    refId = "A";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "P5DCFC7561CCDE821";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "P5DCFC7561CCDE821";
                      };
                      editorMode = "code";
                      expr = ''
                        network_ups_tools_ups_status{instance="matrix:9199",flag="OB"}
                      '';
                      instant = true;
                      intervalMs = 1000;
                      legendFormat = "__auto";
                      maxDataPoints = 43200;
                      range = false;
                      refId = "A";
                    };
                  }
                  {
                    refId = "C";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "__expr__";
                    model = {
                      conditions = [{
                        evaluator = {
                          params = [ 0 ];
                          type = "gt";
                        };
                        operator = { type = "and"; };
                        query = { params = [ "C" ]; };
                        reducer = {
                          params = [ ];
                          type = "last";
                        };
                        type = "query";
                      }];
                      datasource = {
                        type = "__expr__";
                        uid = "__expr__";
                      };
                      expression = "A";
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      refId = "C";
                      type = "threshold";
                    };
                  }
                ];
                noDataState = "OK";
                execErrState = "Error";
                for = "30s";
                annotations = {
                  description = "";
                  runbook_url = "";
                  summary = "";
                };
                labels = { severity = "critical"; };
                isPaused = false;
              }
              {
                uid = "3792C8F7-C2FF-4EB9-A268-AB22038F151A";
                title = "Networking UPS is on battery power";
                condition = "C";
                data = [
                  {
                    refId = "A";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "P5DCFC7561CCDE821";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "P5DCFC7561CCDE821";
                      };
                      editorMode = "code";
                      expr = ''
                        network_ups_tools_ups_status{instance="controller:9199",flag="OB"}
                      '';
                      instant = true;
                      intervalMs = 1000;
                      legendFormat = "__auto";
                      maxDataPoints = 43200;
                      range = false;
                      refId = "A";
                    };
                  }
                  {
                    refId = "C";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "__expr__";
                    model = {
                      conditions = [{
                        evaluator = {
                          params = [ 0 ];
                          type = "gt";
                        };
                        operator = { type = "and"; };
                        query = { params = [ "C" ]; };
                        reducer = {
                          params = [ ];
                          type = "last";
                        };
                        type = "query";
                      }];
                      datasource = {
                        type = "__expr__";
                        uid = "__expr__";
                      };
                      expression = "A";
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      refId = "C";
                      type = "threshold";
                    };
                  }
                ];
                noDataState = "OK";
                execErrState = "Error";
                for = "30s";
                annotations = {
                  description = "";
                  runbook_url = "";
                  summary = "";
                };
                labels = { severity = "critical"; };
                isPaused = false;
              }
              {
                uid = "e1a38758-5093-49e2-8041-ae81225b1ca5";
                title = "Packet loss is greater than 1%";
                condition = "C";
                data = [
                  {
                    refId = "A";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "P5DCFC7561CCDE821";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "P5DCFC7561CCDE821";
                      };
                      editorMode = "code";
                      expr = ''
                        (smokeping_requests_total{host="1.1.1.1", job="smokeping_controller"} - smokeping_response_duration_seconds_count{host="1.1.1.1", job="smokeping_controller"})/smokeping_requests_total{host="1.1.1.1", job="smokeping_controller"}
                      '';
                      instant = false;
                      intervalMs = 1000;
                      legendFormat = "__auto";
                      maxDataPoints = 43200;
                      range = true;
                      refId = "A";
                    };
                  }
                  {
                    refId = "B";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "__expr__";
                    model = {
                      conditions = [{
                        evaluator = {
                          params = [ 0 0 ];
                          type = "gt";
                        };
                        operator = { type = "and"; };
                        query = { params = [ ]; };
                        reducer = {
                          params = [ ];
                          type = "avg";
                        };
                        type = "query";
                      }];
                      datasource = {
                        name = "Expression";
                        type = "__expr__";
                        uid = "__expr__";
                      };
                      expression = "A";
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      reducer = "mean";
                      refId = "B";
                      type = "reduce";
                    };
                  }
                  {
                    refId = "C";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "__expr__";
                    model = {
                      conditions = [{
                        evaluator = {
                          params = [ 1.0e-2 ];
                          type = "gt";
                        };
                        operator = { type = "and"; };
                        query = { params = [ ]; };
                        reducer = {
                          params = [ ];
                          type = "avg";
                        };
                        type = "query";
                      }];
                      datasource = {
                        name = "Expression";
                        type = "__expr__";
                        uid = "__expr__";
                      };
                      expression = "B";
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      refId = "C";
                      type = "threshold";
                    };
                  }
                ];
                noDataState = "NoData";
                execErrState = "Error";
                for = "5m";
                annotations = {
                  description = "";
                  runbook_url = "";
                  summary = "";
                };
                labels = { severity = "critical"; };
                isPaused = false;
              }
            ];
          }];
        };
      };
    };
  };
}
