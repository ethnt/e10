{ config, ... }: {
  imports = [ ./postgresql.nix ./redis.nix ];

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
      mode = "0660";
    };
  };

  services.tracearr = {
    enable = true;
    openFirewall = true;
    environment = {
      DATABASE_URL = "postgres://tracearr:tracearr@localhost:5432/tracearr";
      REDIS_URL = "redis://localhost:6381";
      TRUST_PROXY = toString true;
    };
    environmentFile = config.sops.templates.tracearr_environment_file.path;
  };
}
