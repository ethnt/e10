{ config, ... }: {
  sops = {
    secrets = {
      thanos_sidecar_object_storage_configuration = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        mode = "0777";
        owner = "prometheus";
      };

      thanos_storage_bucket = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      thanos_storage_aws_access_key_id = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };

      thanos_storage_aws_secret_access_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };
    };

    templates."thanos/sidecar_object_storage_configuration.json" = {
      content = builtins.toJSON {
        type = "S3";
        config = {
          bucket = config.sops.placeholder.thanos_storage_bucket;
          endpoint = "s3.us-east-2.amazonaws.com";
          region = "us-east-2";
          access_key = config.sops.placeholder.thanos_storage_aws_access_key_id;
          secret_key =
            config.sops.placeholder.thanos_storage_aws_secret_access_key;
        };
      };
      mode = "0777";
      owner = "prometheus";
      restartUnits = [
        "thanos-sidecar.service"
        "thanos-store.service"
        "thanos-query.service"
        "thanos-compact.service"
      ];
    };
  };

  services.thanos = {
    sidecar = {
      enable = true;
      http.port = 19190;
      grpc.port = 10900;
      objstore.config-file =
        config.sops.templates."thanos/sidecar_object_storage_configuration.json".path;
    };

    store = {
      enable = true;
      http.port = 19191;
      grpc.port = 10901;
      objstore.config-file =
        config.sops.templates."thanos/sidecar_object_storage_configuration.json".path;
    };

    query = {
      enable = true;
      http.port = 19192;
      grpc.port = 10902;
      endpoints = [
        config.services.thanos.sidecar.grpc-address
        config.services.thanos.store.grpc-address
      ];
    };

    compact = {
      enable = true;
      http.port = 19193;
      objstore.config-file =
        config.sops.templates."thanos/sidecar_object_storage_configuration.json".path;
    };
  };

  systemd.services = let
    additionalServiceConfig = {
      wants = [ "sops-nix.service" ];
      after = [ "sops-nix.service" ];
    };
  in {
    thanos-sidecar = additionalServiceConfig;
    thanos-store = additionalServiceConfig;
    thanos-query = additionalServiceConfig;
    thanos-compact = additionalServiceConfig;
  };
}
