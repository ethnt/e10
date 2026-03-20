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
      inherit (config.services.speedtest-tracker) port;
      proxy = {
        enable = true;
        domain = "speedtest-tracker.e10.camp";
      };
    };
  };
}
