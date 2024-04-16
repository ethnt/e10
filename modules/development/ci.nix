{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { pkgs, system, ... }:
    let
      setup = [
        {
          name = "Checkout code";
          uses = "actions/checkout@v3";
        }
        {
          name = "Install Nix";
          uses = "DeterminateSystems/nix-installer-action@main";
          "with" = { extra-conf = "allow-import-from-derivation = true"; };
        }
        {
          name = "Use Cachix store";
          uses = "cachix/cachix-action@v12";
          "with" = {
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            extraPullNames = "e10,nix-community";
            name = "e10";
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
        on.push.branches = [ "main" ];
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
