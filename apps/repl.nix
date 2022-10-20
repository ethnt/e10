# Lifted from https://github.com/divnix/bud/blob/be38f9205dced7f811481fc236dba6ac534fd660/scripts/utils-repl/repl.nix
{ flakePath, host, }:
let
  Flake = if builtins.pathExists flakePath then
    builtins.getFlake (toString flakePath)
  else
    { };
  Me = Flake.darwinConfigurations.${host} or { };
  Channels = Flake.pkgs.${builtins.currentSystem} or { };
  LoadFlake = path: builtins.getFlake (toString path);
in { inherit Channels Flake LoadFlake Me; }
