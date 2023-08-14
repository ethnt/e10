{ inputs, self, config, withSystem, ... }:
let
  haumea = inputs.haumea.lib;
  lib = haumea.load {
    src = ./src;
    inputs = {
      inherit withSystem;
      flake = { inherit self inputs config; };
    };
  };
in { flake.lib = lib; }
