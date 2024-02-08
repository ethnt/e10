{
  services.telegraf = {
    enable = true;
    extraConfig = { outputs = { prometheus_client.listen = ":9273"; }; };
  };
}
