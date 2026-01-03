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
                    title = "Huntarr";
                    url = "https://huntarr.e10.camp";
                    icon =
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/huntarr.png";
                  }
                  {
                    title = "Wizarr";
                    url = "https://join.e10.video";
                    icon = "di:wizarr";
                  }
                  {
                    title = "Bazarr";
                    url = "https://bazarr.e10.camp";
                    icon = "di:bazarr";
                    alt-status-codes = [ 401 ];
                  }
                  {
                    title = "Fileflows";
                    url = "https://fileflows.e10.camp";
                    check-url = "https://fileflows.e10.camp/manifest.json";
                    icon = "di:fileflows";
                  }
                  {
                    title = "Tautulli";
                    url = "https://tautulli.e10.camp";
                    icon = "di:tautulli";
                  }
                  {
                    title = "e10.land";
                    url = "https://e10.land";
                    icon = "https://e10.land/favicon.ico";
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
                  {
                    title = "BentoPDF";
                    url = "https://pdf.e10.camp";
                    icon = "di:bentopdf";
                    alt-status-codes = [ 401 ];
                  }
                  {
                    title = "Mazanoke";
                    url = "https://mazanoke.e10.camp";
                    # icon = "di:mazanoke";
                    icon =
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/mazanoke.png";
                    alt-status-codes = [ 401 ];
                  }
                  {
                    title = "Authelia";
                    url = "https://auth.e10.camp";
                    icon = "di:authelia";
                  }
                  {
                    title = "LLDAP";
                    url = "https://ldap.e10.camp";
                    icon = "di:lldap";
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
