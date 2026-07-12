{ config, ... }: {
  sops.secrets = {
    mosquitto_frigate_password.sopsFile = ./secrets.json;
    mosquitto_hass_password.sopsFile = ./secrets.json;
    mosquitto_jetkvm_password.sopsFile = ./secrets.json;
  };

  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        users = {
          hass = {
            passwordFile = config.sops.secrets.mosquitto_hass_password.path;
            acl = [
              "readwrite frigate/#"
              "readwrite jetkvm/#"
            ];
          };
          frigate = {
            passwordFile = config.sops.secrets.mosquitto_frigate_password.path;
            acl = [ "readwrite frigate/#" ];
          };
          jetkvm = {
            passwordFile = config.sops.secrets.mosquitto_jetkvm_password.path;
            acl = [ "readwrite jetkvm/#" ];
          };
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = map (
    listener: listener.port
  ) config.services.mosquitto.listeners;
}
