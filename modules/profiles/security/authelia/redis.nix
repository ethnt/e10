{
  services.redis.servers.authelia-bastion = {
    enable = true;
    openFirewall = true;
    bind = "0.0.0.0";
    port = 6380;
    settings = { protected-mode = false; };
  };
}
