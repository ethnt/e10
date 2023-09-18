{
  services.nut.server = {
    enable = true;
    host = "0.0.0.0";
    users = {
      leader.password = "132010";
      follower.password = "132010";
    };
    ups = {
      driver = "usbhid-ups";
      extraDirectives = [ "ignorelb" ];
    };
  };
}
