channels: final: prev: {
  __dontExport = true;

  inherit (channels.nixos-unstable)
    blocky deploy-rs libva-utils radarr sonarr intel-compute-runtime
    intel-media-driver;
}
