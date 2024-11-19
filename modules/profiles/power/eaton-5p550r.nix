{ config, ... }: {
  imports = [ ./common.nix ];

  power.ups = {
    ups.eaton = {
      driver = "usbhid-ups";
      description = "Eaton 5P550R";
      port = "auto";
      directives = [
        "vendorid = 0463"
        "productid = ffff"
        "override.battery.charge.low = 10"
        "override.battery.runtime.low = 180"
      ];
    };

    upsmon.monitor.eaton = {
      user = "leader";
      powerValue = 1;
      type = "master";
      passwordFile = config.sops.secrets.upsmon_password.path;
      system = "eaton@0.0.0.0:3493";
    };
  };
}
