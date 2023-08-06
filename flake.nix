{
  description = "e10";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    devenv.url = "github:cachix/devenv";

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
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" ];

      perSystem = { ... }: { };

      flake = { };
    };
}
