{ config, ... }: {
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
    };
  };

  provides.uptime-kuma = {
    name = "Uptime Kuma";
    http = {
      enable = true;
      port = config.services.uptime-kuma.settings.PORT;
      domain = "status.e10.video";
    };
  };
}
