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

          nixpkgs-blocky-0-31 = import inputs.nixpkgs-blocky-0-31 {
            inherit system;

            config = {
              allowUnfree = true;
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
            prometheus-dcgm-exporter
            immich
            ;

          # Avoiding EDNS0 bug: https://github.com/0xERR0R/blocky/issues/2212
          inherit (nixpkgs-blocky-0-31) blocky;

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
