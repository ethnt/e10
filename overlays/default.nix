{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { system, ... }:
    let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config.allowUnfree = true;
      };
    in {
      overlayAttrs = {
        inherit (nixpkgs-master) prowlarr radarr sabnzbd sonarr;
      };
    };
}
