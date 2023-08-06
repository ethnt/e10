{
  description = "e10";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        treefmt.flakeModule

        ./modules/development/shell.nix
        ./modules/development/dhall.nix
        ./modules/development/treefmt.nix
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: { };

      flake = { };
    };
}
