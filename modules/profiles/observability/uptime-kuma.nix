{ config, ... }: {
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
    };
  };

  provides.services.uptime-kuma = {
    name = "Uptime Kuma";
    http = {
      port = config.services.uptime-kuma.settings.PORT;
      proxy = {
        enable = true;
        domain = "status.e10.video";
      };
    };
  };
}
