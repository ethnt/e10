{
  description = "e10";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        devenv.flakeModule
        treefmt.flakeModule

        ./modules/development/shell.nix
        ./modules/development/dhall.nix
        ./modules/development/treefmt.nix

        ./modules/terraform/package.nix
        ./modules/terraform/shell.nix
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" ];

      perSystem = { ... }: { };

      flake = { };
    };
}
