{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { system, self', ... }: {
    overlayAttrs = let
      nixpkgs-master = import inputs.nixpkgs-master {
        inherit system;

        config.allowUnfree = true;
      };

      nixpkgs-24-05 = import inputs.nixpkgs-24-05 {
        inherit system;

        config.allowUnfree = true;
      };
    in {
      inherit (nixpkgs-master) prowlarr radarr sabnzbd sonarr netbox;
      inherit (nixpkgs-master.python312Packages) pymdown-extensions onnx;

      inherit (nixpkgs-24-05) prometheus-pve-exporter;

      inherit (self'.packages) overseerr mongodb-ce-6_0;
    };
  };
}
