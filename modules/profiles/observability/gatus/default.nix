{ config, ... }: {
  imports = [ ./postgresql.nix ];

  sops = {
    secrets = {
      gatus_authelia_basic_auth.sopsFile = ./secrets.json;
      gatus_ntfy_token.sopsFile = ./secrets.json;
    };

    templates."gatus/environment_file" = {
      content = ''
        GATUS_LOG_LEVEL=warn

        AUTHELIA_BASIC_AUTH=${config.sops.placeholder.gatus_authelia_basic_auth}
        NTFY_TOKEN=${config.sops.placeholder.gatus_ntfy_token}
      '';
      mode = "0660";
      restartUnits = [ "gatus.service" ];
    };
  };

  services.gatus = {
    enable = true;
    openFirewall = true;
    environmentFile = config.sops.templates."gatus/environment_file".path;
    settings = {
      metrics = true;
      storage = {
        type = "postgres";
        path = "postgresql:///gatus?host=/run/postgresql";
        maximum-number-of-results = 1000;
        maximum-number-of-events = 1000;
      };
      connectivity.checker = {
        target = "1.1.1.1:53";
        interval = "30s";
      };
    };
  };
}
