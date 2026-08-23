{
  lib,
  config,
  hosts,
  ...
}:
{
  systemd.services.vector.environment.VECTOR_LOG_FORMAT = "json";

  services.vector = {
    enable = true;

    settings = {
      api.enabled = true;

      sinks.loki = {
        type = "loki";
        inputs = [ ];
        endpoint = "http://${hosts.monitor.config.networking.hostName}:${toString hosts.monitor.config.services.loki.configuration.server.http_listen_port}";
        encoding = {
          codec = "json";
          except_fields = [ "labels" ];
          timestamp_format = "rfc3339";
        };

        labels."*" = "{{ labels }}";
      }
      # Vector >= 0.57 blocks unconfined template resolution (as used by the
      # `labels."*"` wildcard above) unless explicitly opted in. The field was
      # introduced in 0.57.0 and does not exist on the older Vector shipped with
      # the Raspberry Pi hosts' nixpkgs (26.05, currently 0.55), so only set it
      # where the running Vector supports it.
      // lib.optionalAttrs (lib.versionAtLeast config.services.vector.package.version "0.57.0") {
        dangerously_allow_unconfined_template_resolution = true;
      };
    };
  };
}
