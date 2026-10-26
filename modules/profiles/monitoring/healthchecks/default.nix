{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets = {
    healthchecks_secret_key = {
      sopsFile = ./secrets.json;
      owner = config.services.healthchecks.user;
    };

    healthchecks_smtp2go_password = {
      sopsFile = ./secrets.json;
      owner = config.services.healthchecks.user;
    };
  };

  services.healthchecks = {
    enable = true;
    package = pkgs.healthchecks.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        sed -i '/^EMAIL_HOST_PASSWORD_FILE = /,/^$/d' $out/opt/healthchecks/hc/local_settings.py
        if grep -q EMAIL_HOST_PASSWORD $out/opt/healthchecks/hc/local_settings.py; then
          echo "failed to strip EMAIL_HOST_PASSWORD from local_settings.py" >&2
          exit 1
        fi
      '';
    });
    listenAddress = "0.0.0.0";
    port = 9075;
    settings = {
      ADMINS = lib.strings.join "," [ "ethan+e10@turkeltaub.dev" ];
      SECRET_KEY_FILE = config.sops.secrets.healthchecks_secret_key.path;
      DEFAULT_FROM_EMAIL = "Healthchecks <monitor@e10.camp>";
      EMAIL_HOST = "mail.smtp2go.com";
      EMAIL_PORT = "2525";
      EMAIL_USE_TLS = "True";
      EMAIL_HOST_USER = "e10_smtp";
      EMAIL_HOST_PASSWORD_FILE = config.sops.secrets.healthchecks_smtp2go_password.path;
    };
  };
}
