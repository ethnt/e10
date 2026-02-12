{ config, lib, ... }: {
  sops = {
    secrets = {
      glance_authelia_basic_auth_username = { sopsFile = ./secrets.json; };
      glance_authelia_basic_auth_password = { sopsFile = ./secrets.json; };
    };

    templates.glance_environment_file = {
      content = ''
        AUTHELIA_BASIC_AUTH_USERNAME=${config.sops.placeholder.glance_authelia_basic_auth_username}
        AUTHELIA_BASIC_AUTH_PASSWORD=${config.sops.placeholder.glance_authelia_basic_auth_password}
      '';
      mode = "0700";
    };
  };

  services.glance = {
    enable = true;
    environmentFile = config.sops.templates.glance_environment_file.path;
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
                sites = let
                  mkSite =
                    { title, url, check-url ? null, icon, basicAuth ? false }: {
                      inherit title url check-url icon;
                      basic-auth = lib.mkIf basicAuth {
                        username = "\${AUTHELIA_BASIC_AUTH_USERNAME}";
                        password = "\${AUTHELIA_BASIC_AUTH_PASSWORD}";
                      };
                    };
                in [
                  (mkSite {
                    title = "Authelia";
                    url = "https://auth.e10.camp";
                    icon = "di:authelia";
                  })
                  (mkSite {
                    title = "Authelia (Monitor)";
                    url = "https://auth.monitor.e10.camp";
                    icon = "di:authelia";
                  })
                  (mkSite {
                    title = "Bazarr";
                    url = "https://bazarr.e10.camp";
                    icon = "di:bazarr";
                  })
                  (mkSite {
                    title = "BentoPDF";
                    url = "https://pdf.e10.camp";
                    icon = "di:bentopdf";
                    basicAuth = true;
                  })
                  (mkSite {
                    title = "Bichon";
                    url = "https://bichon.e10.camp";
                    icon = "sh:bichon";
                  })
                  (mkSite {
                    title = "Change Detection";
                    url = "https://change-detection.e10.camp";
                    icon = "di:changedetection";
                    basicAuth = true;
                  })
                  (mkSite {
                    title = "e10.land";
                    url = "https://e10.land";
                    icon = "https://e10.land/favicon.ico";
                  })
                  (mkSite {
                    title = "Fileflows";
                    url = "https://fileflows.e10.camp";
                    icon = "di:fileflows";
                    basicAuth = true;
                  })
                  (mkSite {
                    title = "Frigate";
                    url = "http://htpc:5000";
                    icon = "di:frigate";
                  })
                  (mkSite {
                    title = "Gatus";
                    url = "https://status.e10.camp";
                    icon = "di:gatus";
                  })
                  (mkSite {
                    title = "Grafana";
                    url = "https://grafana.e10.camp";
                    icon = "di:grafana";
                  })
                  (mkSite {
                    title = "Home Assistant";
                    url = "https://hass.e10.camp";
                    icon = "di:home-assistant";
                  })
                  (mkSite {
                    title = "Huntarr";
                    url = "https://huntarr.e10.camp";
                    icon =
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/huntarr.png";
                  })
                  (mkSite {
                    title = "Immich";
                    url = "https://immich.e10.camp";
                    icon = "di:immich";
                  })
                  (mkSite {
                    title = "Jellyseerr";
                    url = "https://requests.e10.video";
                    icon = "di:jellyseerr";
                  })
                  (mkSite {
                    title = "Karakeep";
                    url = "https://karakeep.e10.camp";
                    icon = "di:karakeep";
                  })
                  (mkSite {
                    title = "LLDAP";
                    url = "https://ldap.e10.camp";
                    icon = "di:lldap";
                  })
                  (mkSite {
                    title = "Mazanoke";
                    url = "https://mazanoke.e10.camp";
                    icon =
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/mazanoke.png";
                    basicAuth = true;
                  })
                  (mkSite {
                    title = "Miniflux";
                    url = "https://feeds.e10.camp";
                    icon = "di:miniflux";
                  })
                  (mkSite {
                    title = "Netbox";
                    url = "https://netbox.e10.camp";
                    icon = "di:netbox";
                  })
                  (mkSite {
                    title = "Paperless";
                    url = "https://paperless.e10.camp";
                    icon = "di:paperless";
                  })
                  (mkSite {
                    title = "Plex";
                    url = "https://e10.video";
                    check-url = "https://e10.video/identity";
                    icon = "di:plex";
                  })
                  (mkSite {
                    title = "Profilarr";
                    url = "https://profilarr.e10.camp";
                    icon = "di:profilarr";
                  })
                  (mkSite {
                    title = "Prowlarr";
                    url = "https://prowlarr.e10.camp";
                    icon = "di:prowlarr";
                  })
                  (mkSite {
                    title = "Radarr";
                    url = "https://radarr.e10.camp";
                    icon = "di:radarr";
                  })
                  (mkSite {
                    title = "SABnzbd";
                    url = "https://sabnzbd.e10.camp";
                    icon = "di:sabnzbd";
                  })
                  (mkSite {
                    title = "Sonarr";
                    url = "https://sonarr.e10.camp";
                    icon = "di:sonarr";
                  })
                  (mkSite {
                    title = "Tautulli";
                    url = "https://tautulli.e10.camp";
                    icon = "di:tautulli";
                  })
                  (mkSite {
                    title = "Termix";
                    url = "https://termix.e10.camp";
                    icon = "di:termix";
                  })
                  (mkSite {
                    title = "Tracearr";
                    url = "https://tracearr.e10.camp";
                    icon = "di:tracearr";
                  })
                  (mkSite {
                    title = "UniFi";
                    url = "https://unifi.satan.network";
                    icon = "di:unifi";
                  })
                  (mkSite {
                    title = "Wizarr";
                    url = "https://join.e10.video";
                    icon = "di:wizarr";
                  })
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
