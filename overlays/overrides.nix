channels: final: prev: {
  __dontExport = true;

  inherit (channels.nixos-unstable) blocky deploy-rs radarr sonarr;
}
