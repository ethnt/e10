{
  description = "e10";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters =
    "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys =
    "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= e10.cachix.org-1:/++Tmo/ghEqnLwsQJdXn04c262agRCK5PaPYz8NcVfo=";

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

  outputs = { self, digga, nixos, nixos-hardware, nixos-generators, sops-nix
    , deploy, nixpkgs, ... }@inputs:
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

        hosts = {
          gateway = { };
          monitor = { };
          matrix = { };

          template = { };
        };

        importables = rec {
          hosts = self.nixosConfigurations;
          profiles = digga.lib.rakeLeaves ./profiles;
          suites = with profiles; rec {
            base = [
              core.nix-config
              core.tooling
              networking.mosh
              networking.openssh
              system.earlyoom
              security.fail2ban
              users.root
              shell.fish
              backups.borg
            ];
            network = [ networking.nebula.peer ];
            aws = [ virtualisation.aws ];
            proxmox = [ virtualisation.proxmox ];
            observability =
              [ monitoring.prometheus-node-exporter monitoring.promtail ];
            web = [ web-servers.nginx monitoring.prometheus-nginx-exporter ];

            gateway = [
              networking.nebula.lighthouse
              networking.blocky.common
              databases.postgresql.common
              databases.postgresql.blocky
            ];
            monitor = [
              monitoring.prometheus
              monitoring.grafana
              monitoring.loki
            ];
            matrix = [
              databases.redis.blocky
              networking.blocky.common
              networking.blocky.local
              networking.unifi
              power.apcupsd
              monitoring.prometheus-apcupsd-exporter
              applications.e10-land
              hardware.nuc
              networking.printing
              networking.avahi
              applications.miniflux
              databases.postgresql.common
              databases.postgresql.blocky
              applications.home-assistant
            ];
            htpc = [
              virtualisation.docker
              hardware.intel-graphics
              hardware.nuc
              media-management.prowlarr
              media-management.sonarr
              media-management.radarr
              media-management.sabnzbd
              media-management.plex
              media-management.bazarr
              media-management.tautulli
              media-management.overseerr
              media-management.xteve
            ];
          };
        };
      };

      devshell = ./shell;

      deploy.nodes = let inherit (self.lib) deployableHosts mkDeployNode;
      in digga.lib.mkDeployNodes (deployableHosts self.nixosConfigurations) {
        gateway = mkDeployNode { hostname = "gateway.e10.network"; };
        monitor = mkDeployNode { hostname = "monitor.e10.network"; };
        htpc = mkDeployNode { hostname = "192.168.1.203"; };
        matrix = mkDeployNode { hostname = "192.168.1.202"; };
      };

      outputsBuilder = channels:
        let pkgs = channels.nixos-unstable;
        in {
          apps = import ./apps { inherit self pkgs; };
          checks = import ./checks { inherit self pkgs; };
        };
    };
}
