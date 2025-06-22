{ config, profiles, ... }: {
  imports = [ profiles.databases.postgresql.opengist ];

  sops.secrets = {
    opengist_oauth_secrets = {
      sopsFile = ./secrets.yml;
      format = "yaml";
      owner = "opengist";
    };
  };

  services.opengist = {
    enable = true;
    settings = {
      "db-uri" = "postgres://opengist@localhost:5432/opengist";
      external-url = "https://gist.e10.camp";
      "oidc.provider-name" = "authelia";
      "oidc.client-key" = "opengist";
      "oidc.discovery-url" =
        "https://auth.e10.camp/.well-known/openid-configuration";
    };
  };

  systemd.services.opengist = {
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.opengist_oauth_secrets.path;
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.opengist.settings."http.port"
    config.services.opengist.settings."ssh.port"
  ];
}
