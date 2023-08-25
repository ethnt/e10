{ self, ... }:
let
  inherit (self) inputs;
  inherit (inputs) haumea;
in haumea.lib.load {
  src = ./.;
  loader = haumea.lib.loaders.path;
}
