{
  services.nut.server = {
    enable = true;
    ups = {
      name = "tripplite";
      description = "Tripp-Lite SMART1500LCD";
      driver = "usbhid-ups";
      vendorid = "09ae";
      productid = "2012";
    };
  };
}
