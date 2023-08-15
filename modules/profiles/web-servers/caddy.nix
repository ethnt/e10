{ config, ... }: {
  services.caddy = {
    enable = true;
    globalConfig = ''
      admin ${config.e10.privateAddress}:2019
    '';
  };
}
