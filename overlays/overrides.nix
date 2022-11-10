channels: final: prev: {
  __dontExport = true;

  inherit (channels.nixos-unstable)
    bazarr blocky cachix deploy-rs dhall nix-index nixfmt prowlarr radarr
    sabnzbd sonarr;
}
