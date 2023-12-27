{ config, ... }: {
  imports = [ ./common.nix ];

  power.ups = {
    ups.tripplite = {
      driver = "usbhid-ups";
      description = "Tripp-Lite SMART1500LCD";
      port = "auto";
      directives = [
        "vendorid = 09ae"
        "productid = 2012"
        "override.battery.charge.low = 25"
        "override.battery.runtime.low = 360"
      ];
    };

    upsmon.monitor.tripplite = {
      user = "leader";
      powerValue = 1;
      type = "master";
      passwordFile = config.sops.secrets.upsmon_password.path;
      system = "tripplite@0.0.0.0:3493";
    };
  };
}
