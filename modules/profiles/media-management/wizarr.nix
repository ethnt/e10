{ config, ... }: {
  services.wizarr = {
    enable = true;
    openFirewall = true;
  };

  provides.wizarr = {
    name = "Wizarr";
    http = {
      inherit (config.services.wizarr) port;
      proxy = {
        enable = true;
        domain = "join.e10.video";
      };
    };
  };
}
