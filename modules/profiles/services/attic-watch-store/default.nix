{ config, ... }: {
  sops.secrets = {
    attic_e10_auth_token = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    attic_netrc_file = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };
  };

  services.attic-watch-store = {
    enable = true;
    server = {
      endpoint = "https://cache.e10.camp";
      name = "cache";
    };
    cache = {
      name = "e10";
      authTokenFile = config.sops.secrets.attic_e10_auth_token.path;
      netrcFile = config.sops.secrets.attic_netrc_file.path;
    };
  };
}
