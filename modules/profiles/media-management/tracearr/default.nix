# NOTE: If Tracearr fails to start because of error similar to `error: could
# not access file "$libdir/timescaledb-2.24.0"`, this can be fixed by running
# `ALTER EXTENSION timescaledb UPDATE;` in the `tracearr` database
#
# See: https://github.com/NixOS/nixpkgs/issues/214367
{ config, ... }: {
  sops.secrets = {
    maxmind_license_key = {
      sopsFile = ./secrets.yml;
      format = "yaml";
    };

    tracearr_auth_secret = {
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

  services.tracearr = {
    enable = true;
    openFirewall = true;
    authSecretFile = config.sops.secrets.tracearr_auth_secret.path;
    cookieSecretFile = config.sops.secrets.tracearr_cookie_secret.path;
    jwtSecretFile = config.sops.secrets.tracearr_jwt_secret.path;
    maxmindLicenseKeyFile = config.sops.secrets.maxmind_license_key.path;
    trustProxy = true;
  };

  services.postgresqlBackup.databases = [ "tracearr" ];
}
