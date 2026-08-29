{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      system,
      self',
      pkgs,
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
        in
        {
          multiverse = inputs.nixpkgs-multiverse.lib.mkMultiverse {
            inherit system;
            config.allowUnfree = true;
          };

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
            handbrake
            karakeep
            ;

          # This is to pick up bugfix here: https://github.com/thanos-io/thanos/issues/7923
          inherit (nixpkgs-master) thanos;

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
            wizarr
            ;

          pythonPackagesExtensions = pkgs.pythonPackagesExtensions ++ [
            (_pyfinal: pyprev: {
              # https://github.com/NixOS/nixpkgs/issues/542586
              paho-mqtt = pyprev.paho-mqtt.overridePythonAttrs (_: {
                doCheck = false;
              });
            })
          ];
        };
    };
}
