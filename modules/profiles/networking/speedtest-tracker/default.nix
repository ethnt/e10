{ config, lib, ... }: {
  sops.secrets.speedtest_tracker_app_key = {
    sopsFile = ./secrets.json;
    mode = "0777";
  };

  services.speedtest-tracker = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.speedtest_tracker_app_key.path;
      APP_URL = "https://speedtest-tracker.e10.camp";
      SPEEDTEST_SCHEDULE = "5 * * * *";
      SPEEDTEST_SERVERS = lib.strings.concatStringsSep "," [ "30514" ];
    };
    enableNginx = true;
    virtualHost = "speedtest-tracker";
  };

  services.nginx.virtualHosts."speedtest-tracker".listen = [
    {
      addr = "0.0.0.0";
      port = 8881;
    }
  ];
}
