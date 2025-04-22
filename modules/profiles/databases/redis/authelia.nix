{
  services.redis.servers.authelia-gateway = {
    enable = true;
    openFirewall = true;
    bind = "0.0.0.0";
    port = 6380;
    settings = { protected-mode = false; };
  };
}
