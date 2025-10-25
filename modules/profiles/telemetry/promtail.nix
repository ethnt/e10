{ hosts, ... }: {
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 28183;
        grpc_listen_port = 0;
      };

      positions.filename = "/tmp/positions.yml";

      clients = [{
        url = "http://${hosts.monitor.config.networking.hostName}:${
            toString
            hosts.monitor.config.services.loki.configuration.server.http_listen_port
          }/loki/api/v1/push";
      }];

      scrape_configs = [{
        job_name = "journal";
        journal = {
          json = true;
          max_age = "12h";
          labels.job = "systemd-journal";
        };
        pipeline_stages = [
          {
            json.expressions = {
              transport = "_TRANSPORT";
              unit = "_SYSTEMD_UNIT";
              msg = "MESSAGE";
            };
          }
          {
            # Set the unit (defaulting to the transport like audit and kernel)
            template = {
              source = "unit";
              template = "{{if .unit}}{{.unit}}{{else}}{{.transport}}{{end}}";
            };
          }
          {
            # Normalize session IDs (session-1234.scope -> session.scope) to limit number of label values
            replace = {
              source = "unit";
              expression = "^(session-\\d+.scope)$";
              replace = "session.scope";
            };
          }
          { labels.unit = "unit"; }
          {
            # Write the proper message instead of JSON
            output.source = "msg";
          }
          # Silence OOM
          {
            drop.expression = "adaptive sleep time: 100 ms";
          }
          # ignore random portscans on the internet
          { drop.expression = "refused connection: IN="; }
        ];
        relabel_configs = [{
          source_labels = [ "__journal__hostname" ];
          target_label = "host";
        }];
      }];
    };
  };
}
