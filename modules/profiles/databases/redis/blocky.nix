{
  services.redis.servers.blocky = {
    enable = true;
    openFirewall = true;
    bind = "0.0.0.0";
    port = 6379;
    settings = { protected-mode = false; };
  };
}
