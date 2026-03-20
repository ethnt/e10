{ config, ... }: {
  services.changedetection-io = {
    enable = true;
    listenAddress = "0.0.0.0";
    behindProxy = true;
    baseURL = "https://change-detection.e10.camp";
    webDriverSupport = true;
  };

  provides.change-detection = {
    name = "Change Detection";
    http = {
      inherit (config.services.changedetection-io) port;
      proxy = {
        enable = true;
        domain = "change-detection.e10.camp";
        protected = true;
      };
    };
  };
}
