{
  description = "e10";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://e10.cachix.org"
      "https://numtide.cachix.org"
      "https://attic.e10.camp"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "e10.cachix.org-1:/++Tmo/ghEqnLwsQJdXn04c262agRCK5PaPYz8NcVfo="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "attic.e10.camp-e10:GRxL2EezM+0vZXpa9fePFqTM1qstxiV56tc5K3eDugk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-registry.url = "github:NixOS/flake-registry";
    flake-registry.flake = false;

    nixos-anywhere.url = "github:numtide/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.inputs.disko.follows = "disko";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        devenv.flakeModule
        treefmt.flakeModule

        ./lib

        ./modules/development/shell.nix
        ./modules/development/dhall.nix
        ./modules/development/treefmt.nix

        ./modules/deploy/shell.nix
        ./modules/deploy/configuration.nix
        ./modules/deploy/terraform.nix

        ./hosts
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" ];

      perSystem = { pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;

          # TODO: Make this on a per-system basis, and maybe per-package
          config.allowUnfree = true;
        };
      };

      flake = { };
    };
}
