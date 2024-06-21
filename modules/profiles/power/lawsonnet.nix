{ config, ... }: {
  imports = [ ./common.nix ];

  power.ups = {
    ups.lawsonnet = {
      driver = "usbhid-ups";
      description = "APC Back-UPS RS 1500VA";
      port = "auto";
      directives = [ "vendorid = 051d" "productid = 0002" ];
    };

    upsmon.monitor.lawsonnet = {
      user = "leader";
      powerValue = 1;
      type = "master";
      passwordFile = config.sops.secrets.upsmon_password.path;
      system = "lawsonnet@0.0.0.0:3493";
    };
  };
}
