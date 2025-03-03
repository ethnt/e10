{ config, ... }: {
  sops.secrets = {
    change_detection_environment_file = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.changedetection-io = {
    enable = true;
    webDriverSupport = true;
    listenAddress = "0.0.0.0";
    baseURL = "https://change-detection.e10.camp";
    environmentFile =
      config.sops.secrets.change_detection_environment_file.path;
  };

  networking.firewall.allowedTCPPorts =
    [ config.services.changedetection-io.port ];
}
