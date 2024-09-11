{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { system, self', ... }: {
    overlayAttrs = let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config.allowUnfree = true;
      };
    in {
      inherit (nixpkgs-master) prowlarr radarr sabnzbd sonarr;
      inherit (self'.packages) overseerr;
    };
  };
}
