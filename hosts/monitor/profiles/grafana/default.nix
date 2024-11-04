{ config, profiles, hosts, ... }: {
  imports = [ profiles.observability.grafana ];

  sops.secrets = {
    pushover_user_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "grafana";
    };

    pushover_api_token = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "grafana";
    };

    aws_ses_smtp_username = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "grafana";
    };

    aws_ses_smtp_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "grafana";
    };
  };

  services.grafana = {
    settings.smtp = {
      enabled = true;
      host = "email-smtp.us-east-2.amazonaws.com:465";
      user = "$__file{${config.sops.secrets.aws_ses_smtp_username.path}}";
      password = "$__file{${config.sops.secrets.aws_ses_smtp_password.path}}";
      startTLS_policy = "MandatoryStartTLS";
      skip_verify = true;
      from_address = "monitor@e10.camp";
      from_name = "Grafana";
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
          name = "NGINX";
          options.path = ./provisioning/nginx.json;
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
          options.path = ./provisioning/borgmatic/logs.json;
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
                settings = { addresses = "ethan.turkeltaub+e10@hey.com"; };
              }];
            }
            {
              name = "Pushover";
              receivers = [{
                uid = "10";
                type = "pushover";
                settings = {
                  apiToken =
                    "$__file{${config.sops.secrets.pushover_api_token.path}}";
                  userKey =
                    "$__file{${config.sops.secrets.pushover_user_key.path}}";
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
              receiver = "Pushover";
              object_matchers = [[ "severity" "=" "critical" ]];
            }];
          }];
        };

        rules.settings = {
          apiVersion = 1;
          deleteRules = [ ];
          groups = [{
            orgId = 1;
            name = "Default";
            interval = "60s";
            folder = "Homelab";
            rules = let
              mkBackupRule = { host, uuid }:
                let hostname = host.config.networking.hostName;
                in {
                  uid = uuid;
                  title = "System failed to backup on ${hostname}";
                  condition = "C";
                  data = [
                    {
                      refId = "A";
                      queryType = "range";
                      relativeTimeRange = {
                        from = 86400;
                        to = 0;
                      };
                      datasourceUid = "P8E80F9AEF21F6940";
                      model = {
                        editorMode = "code";
                        expr = ''
                          count_over_time({application="borgmatic", host="${hostname}"} |~ "Failed backup" [$__auto])'';
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        queryType = "range";
                        refId = "A";
                      };
                    }
                    {
                      refId = "B";
                      relativeTimeRange = {
                        from = 86400;
                        to = 0;
                      };
                      datasourceUid = "__expr__";
                      model = {
                        conditions = [{
                          evaluator = {
                            params = [ ];
                            type = "gt";
                          };
                          operator = { type = "and"; };
                          query = { params = [ "B" ]; };
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
                        reducer = "count";
                        refId = "B";
                        type = "reduce";
                      };
                    }
                    {
                      refId = "C";
                      relativeTimeRange = {
                        from = 86400;
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
                        expression = "B";
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        refId = "C";
                        type = "threshold";
                      };
                    }
                  ];
                  noDataState = "OK";
                  execErrState = "Error";
                  for = "5m";
                  annotations = {
                    description = "";
                    runbook_url = "";
                    summary = "";
                  };
                  labels = { };
                  isPaused = false;
                };
            in [
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
              (mkBackupRule {
                host = hosts.omnibus;
                uuid = "5166671F-AEF3-434D-99B4-18C7A32BD708";
              })
              (mkBackupRule {
                host = hosts.monitor;
                uuid = "9FEB48CD-F6ED-4B7A-86DA-A912D67D142C";
              })
              (mkBackupRule {
                host = hosts.htpc;
                uuid = "77EE3CEA-A817-4A48-86D6-62839DE1A713";
              })
              (mkBackupRule {
                host = hosts.matrix;
                uuid = "32B02B4C-282B-447C-91E9-98B196B9390F";
              })
              (mkBackupRule {
                host = hosts.controller;
                uuid = "E52329A1-393E-47B0-B849-7DB025FA47A0";
              })
              (mkBackupRule {
                host = hosts.builder;
                uuid = "9814CF38-373F-4251-BE8A-2438D9C4A88C";
              })
              (mkBackupRule {
                host = hosts.gateway;
                uuid = "75AA8FE9-04D2-4502-B59D-4F2F5BD1DFE0";
              })
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
