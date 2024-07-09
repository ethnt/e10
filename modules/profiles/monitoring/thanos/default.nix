{ config, ... }: {
  sops.secrets = {
    thanos_sidecar_object_storage_configuration = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0777";
      owner = "prometheus";
    };
  };

  services.thanos = {
    sidecar = {
      enable = true;
      http.port = 19190;
      grpc.port = 10900;
      objstore.config-file =
        config.sops.secrets.thanos_sidecar_object_storage_configuration.path;
    };

    store = {
      enable = true;
      http.port = 19193;
      grpc.port = 10901;
      objstore.config-file =
        config.sops.secrets.thanos_sidecar_object_storage_configuration.path;
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
  };
}
