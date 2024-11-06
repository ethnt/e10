{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { system, self', ... }: {
    overlayAttrs = let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config.allowUnfree = true;
      };
    in {
      inherit (nixpkgs-master) prowlarr radarr sabnzbd sonarr netbox;
      inherit (nixpkgs-master.python312Packages) pymdown-extensions onnx;

      inherit (nixpkgs-master) prometheus-borgmatic-exporter;

      inherit (self'.packages) overseerr mongodb-ce-6_0;
    };
  };
}
