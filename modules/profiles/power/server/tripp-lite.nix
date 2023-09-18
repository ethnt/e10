{
  imports = [ ./common.nix ];

  services.nut.server = {
    ups = {
      name = "tripplite";
      description = "Tripp-Lite SMART1500LCD";
      vendorid = "09ae";
      productid = "2012";
      extraDirectives = [
        "override.battery.charge.low = 25"
        "override.battery.runtime.low = 360"
      ];
    };
  };
}
