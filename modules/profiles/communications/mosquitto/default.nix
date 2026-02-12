{ config, ... }: {
  sops.secrets = {
    mosquitto_frigate_password.sopsFile = ./secrets.json;
    mosquitto_hass_password.sopsFile = ./secrets.json;
  };

  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [{
      users = {
        frigate = {
          passwordFile = config.sops.secrets.mosquitto_frigate_password.path;
          acl = [ "readwrite frigate/#" ];
        };
        hass = {
          passwordFile = config.sops.secrets.mosquitto_hass_password.path;
          acl = [ "readwrite frigate/#" ];
        };
      };
    }];
  };

  networking.firewall.allowedTCPPorts =
    map (listener: listener.port) config.services.mosquitto.listeners;
}
