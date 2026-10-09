{ config, pkgs, ... }: {
  sops = {
    secrets = {
      glitchtip_secret_key = {
        sopsFile = ./secrets.json;
      };

      glitchtip_smtp_address = {
        sopsFile = ./secrets.json;
      };
    };

    templates = {
      "glitchtip/environment_file" = {
        content = ''
          SECRET_KEY=${config.sops.placeholder.glitchtip_secret_key}
          EMAIL_URL=${config.sops.placeholder.glitchtip_smtp_address}
          DEFAULT_FROM_EMAIL="errors@e10.camp"
        '';
        owner = config.services.glitchtip.user;
      };
    };
  };

  environment.systemPackages = [ pkgs.glitchtip-cli ];

  services.glitchtip = {
    enable = true;
    package = pkgs.glitchtip.overrideAttrs (old: {
      # Provides the same fix as this commit. Once there's a new release (v6.1.9), this can be removed:
      # https://gitlab.com/glitchtip/glitchtip-backend/-/commit/920a6c6e4bafc308e5226d9742aaea915eb12f64
      postPatch = (old.postPatch or "") + ''
        substituteInPlace apps/event_ingest/javascript_event_processor.py \
          --replace-fail "frame.colno - 1," "frame.colno,"
      '';
    });
    settings = {
      GLITCHTIP_DOMAIN = "https://errors.e10.camp";
      CSRF_TRUSTED_ORIGINS = "https://errors.e10.camp";
    };
    environmentFiles = [ config.sops.templates."glitchtip/environment_file".path ];
  };
}
