{ config, ... }: {
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  provides.jellyseerr = {
    name = "Jellyseer";
    http = {
      enable = true;
      inherit (config.services.jellyseerr) port;
      domain = "requests.e10.video";
    };
  };
}
