{ config, ... }: {
  services.mazanoke = {
    enable = true;
    openFirewall = true;
  };

  provides.mazanoke = {
    name = "Mazanoke";
    http = {
      enable = true;
      inherit (config.services.mazanoke) port;
      domain = "mazanoke.e10.camp";
      protected = true;
      extraVirtualHostConfig = ''
        request_body {
          max_size 2GiB
        }
      '';
    };
  };
}
