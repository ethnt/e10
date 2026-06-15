{ config, ... }: {
  sops.secrets.profilarr_oidc_client_secret = {
    sopsFile = ./secrets.json;
    owner = config.services.profilarr.user;
    mode = "0700";
  };

  services.profilarr = {
    enable = true;
    origin = "https://profilarr.e10.camp";
    parser = {
      enable = true;
      port = 5001;
    };
    oidc = {
      enable = true;
      clientID =
        "a8Jy2n_CgUOu~nTlLlkgZQV7xJmhq5aW1N0eNePghiFL0Su5jysCJKOpaEpjvRd7yhhz589E";
      clientSecretFile = config.sops.secrets.profilarr_oidc_client_secret.path;
      discoveryURL = "https://auth.e10.camp/.well-known/openid-configuration";
    };
    openFirewall = true;
  };
}
