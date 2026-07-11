{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      system,
      self',
      ...
    }:
    {
      overlayAttrs =
        let
          nixpkgs-master = import inputs.nixpkgs-master {
            inherit system;

            config = {
              allowUnfree = true;
              permittedInsecurePackages = [
                "dotnet-sdk-6.0.428"
                "aspnetcore-runtime-6.0.36"
                "pnpm-9.15.9"
              ];
            };
          };

          nixpkgs-stable = import inputs.nixpkgs-stable {
            inherit system;

            config = {
              allowUnfree = true;
              permittedInsecurePackages = [
                "dotnet-sdk-6.0.428"
                "aspnetcore-runtime-6.0.36"
                "pnpm-9.15.9"
              ];
            };
          };
        in
        {
          inherit (nixpkgs-master)
            gatus
            prowlarr
            radarr
            sabnzbd
            sonarr
            netbox
            plex
            immich
            ;

          # This is to pick up bugfix here: https://github.com/thanos-io/thanos/issues/7923
          inherit (nixpkgs-master) thanos;

          # Avoiding build failure on unstable: https://github.com/NixOS/nixpkgs/issues/540609
          inherit (nixpkgs-stable) gdalMinimal;

          inherit (self'.packages)
            bichon
            decluttarr
            fileflows
            mazanoke
            profilarr
            profilarr-parser
            prometheus-plex-exporter
            tracearr
            unifi-os-server-image
            incus-apply
            ;
        };
    };
}
