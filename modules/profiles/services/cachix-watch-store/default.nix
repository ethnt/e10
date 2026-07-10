{ config, ... }: {
  sops.secrets.cachix_auth_token = {
    sopsFile = ./secrets.json;
  };

  services.cachix-watch-store = {
    enable = true;
    cacheName = "e10";
    cachixTokenFile = config.sops.secrets.cachix_auth_token.path;
  };
}
