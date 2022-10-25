{ config, ... }: {
  sops.secrets = { redis_password = { sopsFile = ./secrets.yaml; }; };

  services.redis = {
    servers = {
      blocky = {
        enable = true;
        port = 6379;
        bind = "0.0.0.0";
        openFirewall = true;
        requirePassFile = config.sops.secrets.redis_password.path;
      };
    };
  };
}
