{ config, profiles, ... }: {
  imports = [ profiles.databases.redis.blocky ];

  services.blocky.settings.redis = {
    address = "${config.services.redis.servers.blocky.bind}:${
        toString config.services.redis.servers.blocky.port
      }";
  };
}
