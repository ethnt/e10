{ config, pkgs, profiles, ... }: {
  imports = [
    profiles.services.matter-server
    profiles.services.go2rtc
    profiles.services.eufy-security-ws.default
  ] ++ [ ./postgresql.nix ];

  sops = {
    secrets = {
      hass_latitude.sopsFile = ./secrets.json;
      hass_longitude.sopsFile = ./secrets.json;
      hass_elevation.sopsFile = ./secrets.json;
      hass_oauth_secret.sopsFile = ./secrets.json;
    };

    templates = {
      hass_secrets = {
        content = ''
          latitude: ${config.sops.placeholder.hass_latitude}
          longitude: ${config.sops.placeholder.hass_longitude}
          elevation: ${config.sops.placeholder.hass_elevation}

          oauth_secret: ${config.sops.placeholder.hass_oauth_secret}
        '';
        path = "/var/lib/hass/secrets.yaml";
        mode = "0777";
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    # See the list of component packages here:
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
    extraComponents = [
      "analytics"
      "apple_tv"
      "brother"
      "ecobee"
      "eufy"
      "google_translate"
      "homekit_controller"
      "hue"
      "ipp"
      "isal"
      "met"
      "opower"
      "radio_browser"
      "sonos"
      "tplink"
    ];

    extraPackages = python3Packages:
      with python3Packages; [
        # HomeKit Bridge
        aiohomekit
        base36
        fnv-hash-fast
        hap-python
        pyqrcode
      ];

    customComponents =
      [ (pkgs.callPackage ./components/eufy_security.nix { }) ];

    config = {
      default_config = { };

      frontend.themes = "!include_dir_merge_named themes";

      automation = "!include automations.yaml";
      script = "!include scripts.yaml";
      scene = "!include scenes.yaml";

      homeassistant = {
        time_zone = "America/New_York";
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "us_customary";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "100.0.0.0/8" ];
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 5353 ];
    allowedTCPPorts = [ 8123 1400 21063 21064 ];
    allowedTCPPortRanges = [{
      from = 21063;
      to = 21068;
    }];
  };
}
