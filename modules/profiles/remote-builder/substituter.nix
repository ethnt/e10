{ config, ... }: {
  sops.secrets = {
    nix_serve_private_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0600";
    };
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets.nix_serve_private_key.path;
    openFirewall = true;
  };
}
