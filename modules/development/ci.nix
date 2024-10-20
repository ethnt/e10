{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { pkgs, system, ... }:
    let
      setup = [
        {
          name = "Checkout code";
          uses = "actions/checkout@v4.2.1";
        }
        {
          name = "Install Nix";
          uses = "DeterminateSystems/nix-installer-action@v14";
          "with" = { extra-conf = "allow-import-from-derivation = true"; };
        }
        {
          name = "Setup Attic cache";
          uses = "ryanccn/attic-action@v0.3.1";
          "with" = {
            endpoint = "https://cache.e10.camp";
            cache = "e10";
            token = "\${{ secrets.ATTIC_TOKEN }}";
          };
        }
        {
          name = "Use Cachix store";
          uses = "cachix/cachix-action@v15";
          "with" = {
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            name = "e10";
            installCommand =
              "nix profile install github:NixOS/nixpkgs/nixpkgs-unstable#cachix";
          };
        }
      ];

      checkWorkflow = {
        name = "Check";
        on.push = { };
        jobs = {
          check = {
            name = "Check flake";
            "runs-on" = "ubuntu-latest";
            steps = setup ++ [{
              run = ''
                nix flake check --impure --accept-flake-config --show-trace
              '';
            }];
          };
        };
      };

      buildWorkflow = {
        name = "Build";
        # on.push.branches = [ "main" ];
        on.push = { };
        jobs = {
          buildSystem = {
            name = "Build system";
            "runs-on" = "ubuntu-latest";
            strategy.matrix.host = l.attrNames (l.filterAttrs
              (_: host: host.config.nixpkgs.system == "x86_64-linux")
              self.nixosConfigurations);
            steps = setup ++ [{
              run = ''
                nix build .#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel --accept-flake-config --show-trace
              '';
            }];
          };
        };
      };

      check = inputs.nixago.lib.${system}.make {
        data = checkWorkflow;
        output = ".github/workflows/check.yml";
        format = "yaml";
        hook.mode = "copy";
      };
      build = inputs.nixago.lib.${system}.make {
        data = buildWorkflow;
        output = ".github/workflows/build.yml";
        format = "yaml";
        hook.mode = "copy";
      };
    in {
      apps = {
        generate-ci.program = pkgs.writeShellScriptBin "generate-ci" ''
          ${check.shellHook}
          ${build.shellHook}
        '';
      };
    };
}
