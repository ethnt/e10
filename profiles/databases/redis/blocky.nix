{ hosts, ... }: {
  services.redis.servers.blocky = {
    enable = true;
    openFirewall = true;
    bind = hosts.matrix.config.e10.privateAddress;
    port = 6379;
    settings = { protected-mode = false; };
  };
}
