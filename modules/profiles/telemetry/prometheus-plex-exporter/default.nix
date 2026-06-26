{ inputs, config, pkgs, ... }: {
  sops.secrets.plex_token = {
    sopsFile = ./secrets.json;
    mode = "0777";
  };

  services.plex-exporter = {
    enable = true;
    package =
      inputs.plex-exporter.packages.${pkgs.stdenv.hostPlatform.system}.default;
    url = "https://e10.video";
    tokenFile = config.sops.secrets.plex_token.path;
    openFirewall = true;
  };
}
