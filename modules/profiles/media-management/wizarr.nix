{ config, ... }: {
  services.wizarr = {
    enable = true;
    openFirewall = true;
  };

  provides.wizarr = {
    name = "Wizarr";
    http = {
      enable = true;
      inherit (config.services.wizarr) port;
      domain = "join.e10.video";
    };
  };
}
