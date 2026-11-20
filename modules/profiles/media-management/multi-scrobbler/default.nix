{ config, ... }: {
  sops = {
    secrets = {
      multi-scrobbler_spotify_client_id = {
        sopsFile = ./secrets.json;
      };

      multi-scrobbler_spotify_client_secret = {
        sopsFile = ./secrets.json;
      };

      multi-scrobbler_koito_token = {
        sopsFile = ./secrets.json;
      };

      multi-scrobbler_listenbrainz_org_token = {
        sopsFile = ./secrets.json;
      };

      multi-scrobbler_rocksky_app_password = {
        sopsFile = ./secrets.json;
      };
    };

    templates.multi_scrobbler_environment_file = {
      content = ''
        SPOTIFY_ID=spotify
        SPOTIFY_NAME=Spotify
        SPOTIFY_ENABLE=true
        SPOTIFY_CLIENT_ID=${config.sops.placeholder.multi-scrobbler_spotify_client_id}
        SPOTIFY_CLIENT_SECRET=${config.sops.placeholder.multi-scrobbler_spotify_client_secret}
        SPOTIFY_REDIRECT_URI=https://multi-scrobbler.e10.camp/callback

        KOITO_ID=koito
        KOITO_NAME=Koito
        KOITO_URL=https://koito.e10.camp
        KOITO_TOKEN=${config.sops.placeholder.multi-scrobbler_koito_token}
        KOITO_USER=ethan

        LZ_ID=listenbrainz
        LZ_NAME=ListenBrainz
        LZ_TOKEN=${config.sops.placeholder.multi-scrobbler_listenbrainz_org_token}
        LZ_USER=ethnt

        ROCKSKY_ID=rocksky
        ROCKSKY_NAME=Rocksky
        ROCKSKY_HANDLE=ethan.haus
        ROCKSKY_APP_PW=${config.sops.placeholder.multi-scrobbler_rocksky_app_password}
      '';
      owner = config.services.multi-scrobbler.user;
      restartUnits = [ "multi-scrobbler.service" ];
    };
  };

  services.multi-scrobbler = {
    enable = true;
    openFirewall = true;
    baseUrl = "https://multi-scrobbler.e10.camp";
    environmentFile = config.sops.templates.multi_scrobbler_environment_file.path;
  };
}
