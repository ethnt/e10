{ hosts, ... }: {
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 5588;
      };
      pages = [{
        name = "Home";
        columns = [
          {
            size = "full";
            widgets = [
              {
                type = "monitor";
                cache = "1m";
                title = "Services";
                sites = [
                  {
                    title = "Plex";
                    url = "https://e10.video";
                    check-url = "https://e10.video/identity";
                    icon = "di:plex";
                  }
                  {
                    title = "Jellyseerr";
                    url = "https://requests.e10.video";
                    icon = "di:jellyseerr";
                  }
                  {
                    title = "Sabnzbd";
                    url = "https://sabnzbd.e10.camp";
                    icon = "di:sabnzbd";
                  }
                  {
                    title = "Sonarr";
                    url = "https://sonarr.e10.camp";
                    icon = "di:sonarr";
                  }
                  {
                    title = "Radarr";
                    url = "https://radarr.e10.camp";
                    icon = "di:radarr";
                  }
                  {
                    title = "Prowlarr";
                    url = "https://prowlarr.e10.camp";
                    icon = "di:prowlarr";
                  }
                  {
                    title = "Bazarr";
                    url = "https://bazarr.e10.camp";
                    icon = "di:bazarr";
                  }
                  {
                    title = "Fileflows";
                    url = "https://fileflows.e10.camp";
                    check-url = "https://fileflows.e10.camp/manifest.json";
                    icon = "di:fileflows";
                  }
                  {
                    title = "Tautulli";
                    url = "https://tautulli.e10.video";
                    icon = "di:tautulli";
                  }
                  {
                    title = "Miniflux";
                    url = "https://feeds.e10.camp";
                    icon = "di:miniflux";
                  }
                  {
                    title = "Paperless";
                    url = "https://paperless.e10.camp";
                    icon = "di:paperless";
                  }
                  {
                    title = "Immich";
                    url = "https://immich.e10.camp";
                    icon = "di:immich";
                  }
                  {
                    title = "Netbox";
                    url = "https://netbox.e10.camp";
                    icon = "di:netbox";
                  }
                  {
                    title = "Grafana";
                    url = "https://grafana.e10.camp";
                    icon = "di:grafana";
                  }
                  {
                    title = "Garage";
                    url = "https://admin.garage.e10.camp/health";
                    icon = "di:garage";
                  }
                  {
                    title = "Attic";
                    url = "https://cache.e10.camp";
                    icon = "di:nixos";
                  }
                  {
                    title = "UniFi";
                    url = "https://unifi.satan.network";
                    icon = "di:unifi";
                  }
                  {
                    title = "Blocky";
                    url =
                      "http://${hosts.controller.config.networking.hostName}:${
                        toString
                        hosts.controller.config.services.blocky.settings.ports.http
                      }/api/blocking/status";
                    icon = "di:blocky";
                  }
                ];
              }
              { type = "lobsters"; }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "clock";
                hour-format = "24h";
                timezones = [
                  {
                    timezone = "UTC";
                    label = "UTC";
                  }
                  {
                    timezone = "Europe/London";
                    label = "London";
                  }
                  {
                    timezone = "America/Los_Angeles";
                    label = "Los Angeles";
                  }
                  {
                    timezone = "America/Phoenix";
                    label = "Phoenix";
                  }
                ];
              }
              {
                type = "calendar";
                first-day-of-week = "sunday";
              }
              {
                type = "weather";
                units = "imperial";
                hour-format = "24h";
                location = "Brooklyn, New York, United States";
              }
            ];
          }
        ];
      }];
    };
    openFirewall = true;
  };
}
