{ config, lib, ... }: {
  services.redis.servers = lib.listToAttrs (lib.imap0 (index: name: {
    name = "authelia-${name}";
    value = {
      enable = true;
      openFirewall = true;
      bind = "0.0.0.0";
      port = 6380 + index;
      settings.protected-mode = false;
    };
  }) (lib.attrNames config.services.authelia.instances));
}
