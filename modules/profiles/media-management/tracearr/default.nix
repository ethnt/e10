# NOTE: If Tracearr fails to start because of error similar to `error: could
# not access file "$libdir/timescaledb-2.24.0"`, this can be fixed by running
# `ALTER EXTENSION timescaledb UPDATE;` in the `tracearr` database
#
# See: https://github.com/NixOS/nixpkgs/issues/214367
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

    templates."tracearr/environment_file" = {
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
    environmentFile = config.sops.templates."tracearr/environment_file".path;
  };
}
