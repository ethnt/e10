{ config, ... }: {
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [ "met" "radio_browser" "hue" "homekit_controller" "apple_tv" "wemo" ];
    config = {
      default_config = { };
      homeassistant = {
        unit_system = "imperial";
        time_zone = config.time.timeZone;
        name = "Home";
        latitude = "40.70";
        longitude = "-73.94";
        external_url = "https://hass.e10.network";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "10.10.0.0/24" ];
      };
    };
    configWritable = true;
  };
}
