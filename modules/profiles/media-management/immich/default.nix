{ config, ... }: {
  sops = {
    secrets = {
      immich_oauth_client_secret = {
        format = "yaml";
        sopsFile = ./secrets.yml;
      };
    };

    templates."immich-config.json" = {
      content = builtins.toJSON {
        server = { externalDomain = "https://immich.e10.camp"; };
        oauth = {
          autoLaunch = false;
          autoRegister = true;
          buttonText = "Login with Authelia";
          clientId =
            "DpimJHTYr-K1ba5dFHj6mlRPXxkQCTN3E3RGljCmVXlGs.AcDdWwG9sysfV~Bv3vq7Z1rEEm";
          clientSecret = config.sops.placeholder.immich_oauth_client_secret;
          defaultStorageQuota = null;
          enabled = true;
          issuerUrl = "https://auth.e10.camp/.well-known/openid-configuration";
          mobileOverrideEnabled = true;
          mobileRedirectUri =
            "https://immich.e10.camp/api/oauth/mobile-redirect";
          scope = "openid email profile";
          signingAlgorithm = "RS256";
          storageLabelClaim = "preferred_username";
          storageQuotaClaim = "immich_quota";
        };
      };
      owner = config.services.immich.user;
      restartUnits = [ "immich-server.service" ];
    };
  };

  services.immich = {
    enable = true;
    openFirewall = true;
    redis.enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/files/services/immich";
    environment = {
      TZ = "America/New_York";
      IMMICH_CONFIG_FILE = config.sops.templates."immich-config.json".path;
    };
  };

  services.postgresqlBackup.databases =
    [ config.services.immich.database.name ];

  systemd.tmpfiles.rules = [
    "d '${config.services.immich.mediaLocation}' 0777 ${config.services.immich.user} ${config.services.immich.group} - -"
  ];
}
