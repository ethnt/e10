{ hosts, ... }: {
  services.vector = {
    enable = true;

    settings = {
      api.enabled = true;

      sinks.loki = {
        type = "loki";
        inputs = [ ];
        endpoint = "http://${hosts.monitor.config.networking.hostName}:${
            toString
            hosts.monitor.config.services.loki.configuration.server.http_listen_port
          }";
        encoding = {
          codec = "json";
          except_fields = [ "labels" ];
          timestamp_format = "rfc3339";
        };

        labels."*" = "{{ labels }}";
      };
    };
  };
}
