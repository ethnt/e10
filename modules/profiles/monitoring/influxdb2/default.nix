{ config, ... }: {
  sops.secrets = {
    influxdb2_admin_password = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "influxdb2";
    };

    influxdb2_token = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      mode = "0700";
      owner = "influxdb2";
    };
  };

  services.influxdb2 = {
    enable = true;
    provision = {
      enable = true;

      initialSetup = {
        bucket = "default";
        organization = "main";
        passwordFile = config.sops.secrets.influxdb2_admin_password.path;
        retention = 0;
        tokenFile = config.sops.secrets.influxdb2_token.path;
        username = "admin";
      };

      organizations.main = { buckets.speedtest-tracker = { retention = 0; }; };

      # users = {
      #   speedtest_tracker.passwordFile = config.sops.secrets.influxdb2_speedtest_tracker_password.path;
      # };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8086 ];
}
