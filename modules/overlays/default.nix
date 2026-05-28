{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { system, self', ... }: {
    overlayAttrs = let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config = {
          allowUnfree = true;
          permittedInsecurePackages =
            [ "dotnet-sdk-6.0.428" "aspnetcore-runtime-6.0.36" ];
        };
      };
    in {
      inherit (nixpkgs-master)
        gatus prowlarr radarr sabnzbd sonarr netbox plex immich;

      inherit (self'.packages) declutarr fileflows mongodb-ce-6_0 tracearr;
    };
  };
}
