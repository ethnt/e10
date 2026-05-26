{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  imports = [ inputs.actions-nix.flakeModules.default ];

  flake.actions-nix.workflows = let
    actions = {
      checkout = "actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd";
      install-lix =
        "samueldr/lix-gha-installer-action@7b7f14d320d6aacfb65bd1ef761566b3b69e474c";
      ssh-agent =
        "webfactory/ssh-agent@e83874834305fe9a4a2997156cb26c5de65a8555";
      attic = "ryanccn/attic-action@1887fd507f03327c96c64cca30118c96eb17fdad";
      cachix = "cachix/cachix-action@1eb2ef646ac0255473d23a5907ad7b04ce94065c";
    };
    setup = [
      {
        name = "Checkout code";
        uses = actions.checkout;
      }
      {
        name = "Install Lix";
        uses = actions.install-lix;
        "with" = {
          extra_nix_config = ''
            accept-flake-config = true
            max-jobs = auto
          '';
        };
      }
      {
        name = "Add SSH keys to ssh-agent";
        uses = actions.ssh-agent;
        "with" = { ssh-private-key = "\${{ secrets.SECRETS_DEPLOY_KEY }}"; };
      }
      {
        name = "Setup Attic cache";
        uses = actions.attic;
        "with" = {
          cache = "e10";
          endpoint = "https://cache.e10.camp";
          token = "\${{ secrets.ATTIC_TOKEN }}";
        };
      }
      {
        name = "Use Cachix store";
        uses = actions.cachix;
        "with" = {
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
          installCommand =
            "nix profile install github:NixOS/nixpkgs/nixpkgs-unstable#cachix";
          name = "e10";
        };
      }
    ];
  in {
    ".github/workflows/check.yml" = {
      name = "Check";
      jobs = {
        check = {
          name = "Check flake";
          steps = setup ++ [{
            name = "Check flake";
            run = "nix flake check --impure --accept-flake-config --show-trace";
          }];
        };
      };
    };

    ".github/workflows/hosts.yml" = {
      name = "Build hosts";
      jobs = {
        buildX86System = {
          name = "Build host system (x86)";
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
              name = "Build \${{ matrix.host }} host system";
              run = ''
                nix build .#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel --accept-flake-config --show-trace
              '';
            }
          ];
        };
        buildARMSystem = {
          name = "Build host system (ARM)";
          "runs-on" = "ubuntu-24.04-arm";
          "if" = ''
            github.ref == 'refs/heads/main' ||
            contains(github.event.head_commit.message, '[build]')
          '';
          strategy.matrix.host = l.attrNames (l.filterAttrs
            (_: host: host.config.nixpkgs.system == "aarch64-linux")
            self.nixosConfigurations);
          steps = setup ++ [{
            name = "Build \${{ matrix.host }} host system";
            run = ''
              nix build .#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel --accept-flake-config --show-trace
            '';
          }];
        };
      };
    };

    ".github/workflows/packages.yml" = {
      name = "Build packages";
      on.push.paths = [ "flake.lock" "modules/packages/**/*.nix" ];
      jobs.buildPackage = {
        name = "Build package";
        runs-on = "\${{ matrix.os }}";
        strategy.matrix = {
          package = l.attrNames self.packages.x86_64-linux;
          architecture = [ "x86_64-linux" "aarch64-linux" ];
          include = [
            {
              architecture = "x86_64-linux";
              os = "ubuntu-24.04";
            }
            {
              architecture = "aarch64-linux";
              os = "ubuntu-24.04-arm";
            }
          ];
        };
        steps = setup ++ [{
          name =
            "Build \${{ matrix.package }} (\${{ matrix.architecture }}) package";
          run = ''
            nix build .#packages.''${{ matrix.architecture }}.''${{ matrix.package }} --keep-going --print-build-logs --show-trace --verbose
          '';
        }];
      };
    };
  };
}
