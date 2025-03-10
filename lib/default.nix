{ inputs, ... }:
let
  haumea = inputs.haumea.lib;
  lib = haumea.load { src = ./src; };
in { flake.lib = lib; }
