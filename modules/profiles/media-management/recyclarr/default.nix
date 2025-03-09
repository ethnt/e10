{ config, pkgs, lib, ... }:
let
  fromYAML = path:
    let
      jsonOutputDrv =
        pkgs.runCommand "from-yaml" { nativeBuildInputs = [ pkgs.remarshal ]; }
        ''remarshal -if yaml -i "${path}" -of json -o "$out"'';
    in builtins.fromJSON (builtins.readFile jsonOutputDrv);
in {
  sops.secrets = {
    recyclarr_radarr_base_url = {
      format = "yaml";
      sopsFile = ./secrets.yml;
    };

    recyclarr_radarr_api_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
    };

    recyclarr_sonarr_base_url = {
      format = "yaml";
      sopsFile = ./secrets.yml;
    };

    recyclarr_sonarr_api_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
    };
  };

  systemd.services.recyclarr.serviceConfig.LoadCredential = [
    "radarr_base_url:${config.sops.secrets.recyclarr_radarr_base_url.path}"
    "radarr_api_key:${config.sops.secrets.recyclarr_radarr_api_key.path}"
    "sonarr_base_url:${config.sops.secrets.recyclarr_sonarr_base_url.path}"
    "sonarr_api_key:${config.sops.secrets.recyclarr_sonarr_api_key.path}"
  ];

  services.recyclarr = {
    enable = true;
    configuration = lib.mkMerge [
      (fromYAML ./config.yml)
      {
        radarr.movies = {
          base_url._secret =
            "/run/credentials/recyclarr.service/radarr_base_url";
          api_key._secret = "/run/credentials/recyclarr.service/radarr_api_key";
        };
        sonarr.tv = {
          base_url._secret =
            "/run/credentials/recyclarr.service/sonarr_base_url";
          api_key._secret = "/run/credentials/recyclarr.service/sonarr_api_key";
        };
      }
    ];
  };
}
