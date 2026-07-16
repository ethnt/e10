{
  services.prometheus.exporters.ping = {
    enable = true;
    settings = {
      ping = {
        interval = "5s";
        timeout = "5s";
      };
    };
    openFirewall = true;
  };
}
