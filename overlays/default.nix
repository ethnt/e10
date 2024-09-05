{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { pkgs, system, ... }:
    let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config.allowUnfree = true;
      };
    in {
      overlayAttrs = {
        inherit (nixpkgs-master) prowlarr radarr sabnzbd sonarr;

        overseerr = pkgs.callPackage ./overseerr { };
      };
    };
}
