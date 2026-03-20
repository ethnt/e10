{ config, ... }: {
  services.profilarr = {
    enable = true;
    openFirewall = true;
  };

  provides.profilarr = {
    name = "Profilarr";
    http = {
      enable = true;
      inherit (config.services.profilarr) port;
      domain = "profilarr.e10.camp";
    };
  };
}
