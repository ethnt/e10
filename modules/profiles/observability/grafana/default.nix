{ config, pkgs, hosts, ... }: {
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

      smtp = {
        enabled = true;
        host = "email-smtp.us-east-2.amazonaws.com:465";
        user = "$__file{${config.sops.secrets.aws_ses_smtp_username.path}}";
        password = "$__file{${config.sops.secrets.aws_ses_smtp_password.path}}";
        startTLS_policy = "MandatoryStartTLS";
        skip_verify = true;
        from_address = "monitor@e10.camp";
        from_name = "Grafana";
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

          groups = [{
            orgId = 1;
            name = "Default";
            interval = "60s";
            folder = "Homelab";
            rules = let
              mkBackupRule = { host, uuid }: {
                uid = uuid;
                title = "System failed to backup on ${host}";
                condition = "A";
                data = [
                  {
                    refId = "A";
                    queryType = "instant";
                    relativeTimeRange = {
                      from = 86400;
                      to = 0;
                    };
                    datasourceUid = "P8E80F9AEF21F6940";
                    model = {
                      editorMode = "code";
                      expr = ''
                        count_over_time({host="host_${host}",unit="borgbackup-job-system.service"} |= "exitStatus=1" [24h])
                      '';
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      queryType = "instant";
                      refId = "A";
                    };
                  }
                  {
                    refId = "B";
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
                      refId = "B";
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
                    datasourceUid = "PBFA97CFB590B2093";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "PBFA97CFB590B2093";
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
                noDataState = "NoData";
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
                    datasourceUid = "PBFA97CFB590B2093";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "PBFA97CFB590B2093";
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
                noDataState = "NoData";
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
                uid = "c4ce282f-6326-419d-819d-cc4a7b44b87c";
                title = "Files failed to backup on omnibus";
                condition = "A";
                data = [
                  {
                    refId = "A";
                    queryType = "instant";
                    relativeTimeRange = {
                      from = 86400;
                      to = 0;
                    };
                    datasourceUid = "P8E80F9AEF21F6940";
                    model = {
                      editorMode = "code";
                      expr = ''
                        count_over_time({host="host_omnibus",unit="borgbackup-job-files.service"} |= "exitStatus=1" [24h])
                      '';
                      intervalMs = 1000;
                      maxDataPoints = 43200;
                      queryType = "instant";
                      refId = "A";
                    };
                  }
                  {
                    refId = "B";
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
                      refId = "B";
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
                labels = { "" = ""; };
                isPaused = false;
              }
              (mkBackupRule {
                host = "omnibus";
                uuid = "D7DC99E9-DA03-4BE5-BFAF-08CDF031E86F";
              })
              (mkBackupRule {
                host = "gateway";
                uuid = "91085D4E-4D6B-4F5E-9872-77EED2EB9E64";
              })
              (mkBackupRule {
                host = "monitor";
                uuid = "9FEB48CD-F6ED-4B7A-86DA-A912D67D142C";
              })
              (mkBackupRule {
                host = "htpc";
                uuid = "77EE3CEA-A817-4A48-86D6-62839DE1A713";
              })
              (mkBackupRule {
                host = "matrix";
                uuid = "32B02B4C-282B-447C-91E9-98B196B9390F";
              })
              (mkBackupRule {
                host = "controller";
                uuid = "E52329A1-393E-47B0-B849-7DB025FA47A0";
              })
              (mkBackupRule {
                host = "builder";
                uuid = "9814CF38-373F-4251-BE8A-2438D9C4A88C";
              })
              {
                uid = "f21a1838-41ba-449e-8830-143a3d86cc0b";
                title = "Blocky is not responding successfully";
                condition = "C";
                data = [
                  {
                    refId = "A";
                    relativeTimeRange = {
                      from = 600;
                      to = 0;
                    };
                    datasourceUid = "PBFA97CFB590B2093";
                    model = {
                      datasource = {
                        type = "prometheus";
                        uid = "PBFA97CFB590B2093";
                      };
                      editorMode = "code";
                      expr =
                        ''{job="blackbox_blocky",__name__="probe_success"}'';
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
                          params = [ 1 ];
                          type = "lt";
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
