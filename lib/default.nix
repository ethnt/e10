{ inputs, ... }:
let
  haumea = inputs.haumea.lib;
  lib = haumea.load {
    src = ./src;
    inputs = { inherit (inputs.nixpkgs) lib; };
  };
in { flake.lib = lib; }
