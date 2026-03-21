{ config, ... }: {
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  provides.jellyseerr = {
    name = "Jellyseer";
    http = {
      inherit (config.services.jellyseerr) port;
      proxy = {
        enable = true;
        domain = "requests.e10.video";
      };
    };
    monitor.enable = true;
  };
}
