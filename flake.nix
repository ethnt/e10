{
  description = "e10";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://e10.cachix.org"
      "https://numtide.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "e10:h64l3MobkrdOGab0Xaambo3ROC/w05Yi70oJ8U8ZEfQ="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-master.url = "github:NixOS/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-anywhere.url = "github:numtide/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.inputs.disko.follows = "disko";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";

    # https://github.com/NixOS/nix/issues/10647#issuecomment-2117844493
    # devenv.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";

    attic.url = "github:zhaofengli/attic";
    attic.inputs.nixpkgs.follows = "nixpkgs";

    flake-root.url = "github:srid/flake-root";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        ./lib

        ./modules/packages/default.nix

        ./modules/overlays

        ./modules/development/shell.nix
        ./modules/development/ci.nix
        ./modules/development/treefmt.nix
        ./modules/development/flake-root.nix

        ./modules/deploy/shell.nix
        ./modules/deploy/configuration.nix
        ./modules/deploy/ansible.nix
        ./modules/deploy/terraform.nix

        ./hosts
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;

          # TODO: Make this on a per-system basis, and maybe per-package
          config.allowUnfree = true;

          overlays = [ self.overlays.default ];
        };
      };
    };
}
