{ lib, ... }: {
  services.vector.settings = {
    sources.syslog = {
      type = "syslog";
      mode = "tcp";
      address = "0.0.0.0:1514";
    };

    transforms.parse_syslog = {
      type = "remap";
      inputs = [ "syslog" ];
      source = ''
        labels = {
          "host": .hostname,
          "application": "syslog",
          "unit": .appname,
          "level": .severity,
          "priority": .severity_code,
          "facility": .facility
        }

        .message = .message
        .timestamp = .timestamp
        .labels = labels
      '';
    };

    sinks.loki.inputs = lib.mkAfter [ "parse_syslog" ];
  };
}
