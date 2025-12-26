_: {
  services.redis.servers.tracearr = {
    enable = true;
    openFirewall = true;
    bind = "0.0.0.0";
    port = 6381;
    settings = { protected-mode = false; };
  };
}
