{ lib, ... }: {
  services.vector.settings = {
    sources.caddy = {
      type = "file";
      include = [ "/var/log/caddy/*log" ];
      read_from = "end";
    };

    transforms = {
      parse_caddy = {
        type = "remap";
        inputs = [ "caddy" ];
        source = ''
          # Parse JSON log if Caddy is configured for JSON output
          . = parse_json!(.message)

          # Extract common fields
          .timestamp = .ts
          .level = .level
          .logger = .logger
          .message = .msg

          proto = "http"
          if .request.tls.proto == "h2" || .request.tls.proto == "h3" {
            proto = "https"
          }

          .labels = {
            "application": "caddy",
            "host": get_hostname!(),
            "level": downcase!(.level),
            "logger": .logger,
            "hostname": .request.host,
            "proto": proto,
            "status": .status
          }
        '';
      };
    };

    sinks.loki.inputs = lib.mkAfter [ "parse_caddy" ];
  };
}
