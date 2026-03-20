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

  provides.nix-serve = {
    name = "nix-serve";
    http = {
      enable = true;
      inherit (config.services.nix-serve) port;
      domain = "cache.builder.e10.camp";
      extraVirtualHostConfig = ''
        request_body {
          max_size 2GiB
        }
      '';
    };
  };
}
