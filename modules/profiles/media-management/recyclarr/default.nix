{ config, ... }: {
  sops.secrets = {
    recyclarr_environment_file = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      owner = "recyclarr";
    };
  };

  services.recyclarr = {
    enable = true;
    configFile = ./config.yml;
    environmentFile = config.sops.secrets.recyclarr_environment_file.path;
  };
}
