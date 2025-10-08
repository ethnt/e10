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
        prowlarr radarr sabnzbd sonarr netbox plex immich;
      inherit (nixpkgs-master.python312Packages) pymdown-extensions onnx;

      # This is to pick up bugfix here: https://github.com/thanos-io/thanos/issues/7923
      inherit (nixpkgs-master) thanos;

      inherit (self'.packages) overseerr mongodb-ce-6_0; # caddy-with-plugins;
    };
  };
}
