{ config, lib, ... }:

with lib;

let
  cfg = config.services.thanos;
  mkAddressPortOption = { defaultAddress ? "0.0.0.0", defaultPort ? 10100 }:
    mkOption {
      type = types.submodule {
        options = {
          address = mkOption {
            type = types.str;
            default = defaultAddress;
          };

          port = mkOption {
            type = types.port;
            default = defaultPort;
          };
        };
      };
    };
in {
  options.services.thanos = {
    sidecar = {
      http = mkAddressPortOption { defaultPort = 19190; };
      grpc = mkAddressPortOption { defaultPort = 10900; };
    };

    store = {
      http = mkAddressPortOption { defaultPort = 19191; };
      grpc = mkAddressPortOption { defaultPort = 10901; };
    };

    query = {
      http = mkAddressPortOption { defaultPort = 19192; };
      grpc = mkAddressPortOption { defaultPort = 10902; };
    };

    compact = { http = mkAddressPortOption { defaultPort = 19193; }; };
  };

  config = {
    services.thanos = {
      sidecar = mkIf cfg.sidecar.enable {
        http-address =
          "${cfg.sidecar.http.address}:${toString cfg.sidecar.http.port}";
        grpc-address =
          "${cfg.sidecar.grpc.address}:${toString cfg.sidecar.grpc.port}";
      };

      store = mkIf cfg.store.enable {
        http-address =
          "${cfg.store.http.address}:${toString cfg.store.http.port}";
        grpc-address =
          "${cfg.store.grpc.address}:${toString cfg.store.grpc.port}";
      };

      query = mkIf cfg.query.enable {
        http-address =
          "${cfg.query.http.address}:${toString cfg.query.http.port}";
        grpc-address =
          "${cfg.query.grpc.address}:${toString cfg.query.grpc.port}";
      };

      compact = mkIf cfg.compact.enable {
        http-address =
          "${cfg.compact.http.address}:${toString cfg.compact.http.port}";
      };
    };
  };
}
