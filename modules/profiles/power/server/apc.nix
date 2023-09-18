{
  imports = [ ./common.nix ];

  services.nut.server = {
    ups = {
      name = "apc";
      description = "APC Back-UPS XS 1500";
      vendorid = "051d";
      productid = "0002";
      extraDirectives = [
        "override.battery.charge.low = 10"
        "override.battery.runtime.low = 180"
      ];
    };
  };
}
