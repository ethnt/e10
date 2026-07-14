{
  services.prometheus.exporters.ping = {
    enable = true;
    settings = {
      targets = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      ping = {
        interval = "5s";
        timeout = "5s";
      };
    };
    openFirewall = true;
  };
}
