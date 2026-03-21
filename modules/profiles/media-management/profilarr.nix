{ config, ... }: {
  services.profilarr = {
    enable = true;
    openFirewall = true;
  };

  provides.profilarr = {
    name = "Profilarr";
    http = {
      inherit (config.services.profilarr) port;
      proxy = {
        enable = true;
        domain = "profilarr.e10.camp";
      };
    };
    monitor.enable = true;
  };
}
