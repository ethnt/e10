{ config, ... }: {
  sops = {
    secrets = {
      maxmind_license_key = {
        sopsFile = ./secrets.yml;
        format = "yaml";
      };

      tracearr_jwt_secret = {
        sopsFile = ./secrets.yml;
        format = "yaml";
      };

      tracearr_cookie_secret = {
        sopsFile = ./secrets.yml;
        format = "yaml";
      };
    };

    templates.tracearr_environment_file = {
      content = ''
        MAXMIND_LICENSE_KEY=${config.sops.placeholder.maxmind_license_key}
        JWT_SECRET=${config.sops.placeholder.tracearr_jwt_secret}
        COOKIE_SECRET=${config.sops.placeholder.tracearr_cookie_secret}
      '';
      owner = config.services.tracearr.user;
      mode = "0777";
    };
  };

  services.tracearr = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.templates.tracearr_environment_file.path;
  };
}
