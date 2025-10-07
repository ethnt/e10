{ config, ... }: {
  services.redis.servers.paperless.enable = true;

  services.paperless.settings.PAPERLESS_REDIS =
    "unix://${config.services.redis.servers.paperless.unixSocket}";

  systemd.services = let
    additionalServiceConfig = {
      serviceConfig.SupplementaryGroups =
        config.services.redis.servers.paperless.user;
      after = [ "redis-paperless.service" ];
    };
  in {
    paperless-scheduler = additionalServiceConfig;
    paperless-task-queue = additionalServiceConfig;
    paperless-consumer = additionalServiceConfig;
    paperless-web = additionalServiceConfig;
  };
}
