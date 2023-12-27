{ config, ... }: {
  sops.secrets = {
    upsmon_password = {
      format = "yaml";
      sopsFile = ../secrets.yml;
      mode = "0400";
    };
  };

  power.ups = {
    enable = true;
    openFirewall = true;
    mode = "netserver";
    upsd = {
      listen = [{
        address = "0.0.0.0";
        port = 3493;
      }];
    };
    ups.tripplite = {
      driver = "usbhid-ups";
      description = "Tripp-Lite SMART1500LCD";
      port = "auto";
      directives = [
        "vendorid = 09ae"
        "productid = 2012"
        "override.battery.charge.low = 25"
        "override.battery.runtime.low = 360"
        "ignorelb"
      ];
    };

    users = {
      leader = {
        upsmon = "master";
        passwordFile = config.sops.secrets.upsmon_password.path;
      };

      follower = {
        upsmon = "slave";
        passwordFile = config.sops.secrets.upsmon_password.path;
      };
    };

    upsmon.monitor.tripplite = {
      user = "leader";
      powerValue = 1;
      type = "master";
      passwordFile = config.sops.secrets.upsmon_password.path;
      system = "tripplite@matrix:3493";
    };
  };
}
