{ config, ... }: {
  services.speedtest-tracker = {
    enable = true;
    schedule = "5 * * * *";
    servers = [ "30514" ];
    openFirewall = true;
  };

  provides.speedtest-tracker = {
    name = "Speedtest Tracker";
    http = {
      enable = true;
      inherit (config.services.speedtest-tracker) port;
      domain = "speedtest-tracker.e10.camp";
    };
  };
}
