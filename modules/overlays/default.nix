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

          nixpkgs-stable = import inputs.nixpkgs-stable {
            inherit system;

            config = {
              allowUnfree = true;
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
            sonarr
            netbox
            plex
            immich
            handbrake
            karakeep
            ;

          # This is to pick up bugfix here: https://github.com/thanos-io/thanos/issues/7923
          inherit (nixpkgs-master) thanos;

          inherit (nixpkgs-stable) vector;

          dcgm = pkgs.dcgm.overrideAttrs { doCheck = false; };

          inherit (self'.packages)
            decluttarr
            faster-whisper-medium
            fileflows
            glitchtip-cli
            grafana-postgresql-plugin
            incus-apply
            mazanoke
            profilarr
            profilarr-parser
            prometheus-plex-exporter
            stable-ts-whisperless
            subgen
            tracearr
            tracearr-basemap
            tunarr
            unifi-os-server-image
            wizarr
            ;

          pythonPackagesExtensions = pkgs.pythonPackagesExtensions ++ [
            (_pyfinal: pyprev: {
              # https://github.com/NixOS/nixpkgs/issues/542586
              paho-mqtt = pyprev.paho-mqtt.overridePythonAttrs (_: {
                doCheck = false;
              });

              # GlitchTip 6.2.6 requires django-organizations ~= 2.7 for `aadd_user`
              django-organizations = pyprev.django-organizations.overridePythonAttrs (old: rec {
                version = "2.7.0";
                src = old.src.override {
                  tag = "v${version}";
                  hash = "sha256-q9E3Dc9Vg3OrQvzXvmz6L1SlY5Cm1wz4CkJAIR5/xA4=";
                };
              });

              # Requires django-async-backend 6.1.5, otherwise get an error like this:
              #   RuntimeError: An async connection can only be used by the task that created it
              django-async-backend = pyprev.django-async-backend.overridePythonAttrs (old: rec {
                version = "6.1.5";
                src = old.src.override {
                  tag = "v${version}";
                  hash = "sha256-kjR0IFQjjTS+2M+2SdzzyDLR/PQtWIU9eUYgLK9PIs8=";
                };
              });
            })
          ];
        };
    };
}
