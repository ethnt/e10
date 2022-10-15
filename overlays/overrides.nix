channels: final: prev: {
  __dontExport = true;

  inherit (channels.nixos-unstable) cachix dhall nix-index nixfmt deploy-rs;
}
