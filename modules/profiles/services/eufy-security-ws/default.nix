{ config, ... }: {
  sops = {
    secrets = {
      eufy_username.sopsFile = ./secrets.json;
      eufy_password.sopsFile = ./secrets.json;
    };

    templates."eufy_security_ws/configuration.json" = {
      content = builtins.toJSON {
        username = config.sops.placeholder.eufy_username;
        password = config.sops.placeholder.eufy_password;
        persistentDir = config.services.eufy-security-ws.dataDir;
        country = "US";
        language = "en";
      };
      mode = "0777";
    };
  };

  services.eufy-security-ws = {
    enable = true;
    configurationFile =
      config.sops.templates."eufy_security_ws/configuration.json".path;
    openFirewall = true;
  };
}
