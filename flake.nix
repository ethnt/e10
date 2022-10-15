{
  description = "camp";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters =
    "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys =
    "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= orchard.cachix.org-1:QfoahY05xLNfFqWoWCELCMz2I8I92n5W8wNRJo+YT2U=";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-22.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.deploy.follows = "deploy";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-generators.url = "github:nix-community/nixos-generators";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, digga, nixos, nixos-hardware, sops-nix, deploy, nixpkgs, ...
    }@inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        nixos-unstable = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: { our = self.lib; });
        })
        sops-nix.overlay
        (import ./pkgs)
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            { lib.our = self.lib; }
            digga.nixosModules.bootstrapIso
            digga.nixosModules.nixConfig
            sops-nix.nixosModules.sops
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];

        hosts = { gateway = { }; };

        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles;
          suites = with profiles; rec {
            base = [
              core.nix-config
              core.tooling
              networking.mosh
              networking.openssh
              networking.nebula.peer
              system.earlyoom
              users.root
            ];

            aws = [ virtualisation.aws ];

            gateway = [ networking.nebula.lighthouse ];
          };
        };
      };

      devshell = ./shell;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {
        gateway = {
          hostname = "3.136.251.131";
          sshUser = "root";
          sshOpts = [ "-i" "keys/id_rsa" ];
        };
      };

      outputsBuilder = channels:
        let pkgs = channels.nixos-unstable;
        in {
          apps = import ./apps { inherit self pkgs; };
          checks = import ./checks { inherit self pkgs; };
        };
    };
}
