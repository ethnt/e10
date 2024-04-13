{ config, pkgs, ... }: {
  imports = [ ./common.nix ];

  power.ups = {
    ups.apc = {
      driver = "usbhid-ups";
      description = "APC Back-UPS XS 1500";
      port = "auto";
      directives = [
        "vendorid = 051d"
        "productid = 0002"
        "override.battery.charge.low = 10"
        "override.battery.runtime.low = 180"
      ];
    };

    upsmon.monitor.apc = {
      user = "leader";
      powerValue = 1;
      type = "master";
      passwordFile = config.sops.secrets.upsmon_password.path;
      system = "apc@0.0.0.0:3493";
    };
  };

  environment = {
    systemPackages = with pkgs; [ apcupsd ];

    etc."apcupsd.conf".text = ''
      ## apcupsd.conf v1.1 ##
      UPSCABLE usb
      UPSTYPE usb
    '';
  };
}
