{ hosts, ... }: {
  services.nut.client = {
    enable = true;
    ups = {
      name = hosts.matrix.config.services.nut.server.ups.name;
      host = hosts.matrix.config.networking.hostName;
      port = hosts.matrix.config.services.nut.server.port;
      username =
        hosts.matrix.config.services.nut.server.users.follower.username;
      password =
        hosts.matrix.config.services.nut.server.users.follower.password;
    };
  };
}
