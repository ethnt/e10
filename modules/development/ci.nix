{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { pkgs, system, ... }:
    let
      setup = [
        {
          name = "Checkout code";
          uses = "actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd";
        }
        {
          name = "Install Lix";
          uses =
            "samueldr/lix-gha-installer-action@7b7f14d320d6aacfb65bd1ef761566b3b69e474c";
          "with" = {
            extra_nix_config = ''
              accept-flake-config = true
              max-jobs = auto
            '';
          };
        }
        {
          name = "Add SSH keys to ssh-agent";
          uses =
            "webfactory/ssh-agent@e83874834305fe9a4a2997156cb26c5de65a8555";
          "with" = { ssh-private-key = "\${{ secrets.SECRETS_DEPLOY_KEY }}"; };
        }
        {
          name = "Setup Attic cache";
          uses =
            "ryanccn/attic-action@1887fd507f03327c96c64cca30118c96eb17fdad";
          "with" = {
            endpoint = "https://cache.e10.camp";
            cache = "e10";
            token = "\${{ secrets.ATTIC_TOKEN }}";
          };
        }
        {
          name = "Use Cachix store";
          uses =
            "cachix/cachix-action@1eb2ef646ac0255473d23a5907ad7b04ce94065c";
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
        on.push = { };
        jobs = {
          buildX86System = {
            name = "Build system (x86)";
            "runs-on" = "ubuntu-latest";
            "if" = ''
              github.ref == 'refs/heads/main' ||
              contains(github.event.head_commit.message, '[build]')
            '';
            strategy.matrix.host = l.attrNames (l.filterAttrs
              (_: host: host.config.nixpkgs.system == "x86_64-linux")
              self.nixosConfigurations);
            steps = setup ++ [
              {
                name = "Clean up storage";
                run = ''
                  sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc /opt/hostedtoolcache/CodeQL
                  sudo docker image prune --all --force
                  sudo docker builder prune -a
                '';
              }
              {
                run = ''
                  nix build .#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel --accept-flake-config --show-trace
                '';
              }
            ];
          };
          buildARMSystem = {
            name = "Build system (ARM)";
            "runs-on" = "ubuntu-24.04-arm";
            "if" = ''
              github.ref == 'refs/heads/main' ||
              contains(github.event.head_commit.message, '[build]')
            '';
            strategy.matrix.host = l.attrNames (l.filterAttrs
              (_: host: host.config.nixpkgs.system == "aarch64-linux")
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
