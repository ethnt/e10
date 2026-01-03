{ config, ... }: {
  sops.secrets = {
    actual_oauth2_client_secret = {
      sopsFile = ./secrets.json;
      mode = "0777";
    };
  };

  services.actual = {
    enable = true;
    openFirewall = true;
    settings = {
      loginMethod = "openid";
      openId = {
        discoveryURL = "https://auth.e10.camp";
        client_id =
          "pV6drSFL4uNhslIfnTxi~oDMhqTIVVWM~307jSrBE9CNPuuwqMRDwYnW0PG6tYYL5HqCpFJu";
        client_secret._secret =
          config.sops.secrets.actual_oauth2_client_secret.path;
        server_hostname = "https://actual.e10.camp";
        authMethod = "oauth2";
      };
    };
  };
}
