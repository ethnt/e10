{ config, ... }: {
  services.mazanoke = {
    enable = true;
    openFirewall = true;
  };

  provides.mazanoke = {
    name = "Mazanoke";
    http = {
      inherit (config.services.mazanoke) port;
      proxy = {
        enable = true;
        domain = "mazanoke.e10.camp";
        protected = true;
        extraVirtualHostConfig = ''
          request_body {
            max_size 2GiB
          }
        '';
      };
    };
  };
}
