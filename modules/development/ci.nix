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

      x86Hosts = l.attrNames
        (l.filterAttrs (_: host: host.config.nixpkgs.system == "x86_64-linux")
          self.nixosConfigurations);
      armHosts = l.attrNames
        (l.filterAttrs (_: host: host.config.nixpkgs.system == "aarch64-linux")
          self.nixosConfigurations);

      detectChanges = pkgs.writeShellApplication {
        name = "detect-changes";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          git fetch --depth=2 origin HEAD 2>/dev/null || true

          get_all_drvs() {
            nix eval --json "$1#nixosConfigurations" \
              --apply 'builtins.mapAttrs (_: v: v.config.system.build.toplevel.drvPath)' \
              --accept-flake-config 2>/dev/null || echo '{}'
          }

          if git rev-parse HEAD~1 >/dev/null 2>&1; then
            prev_dir=$(mktemp -d)
            git worktree add "$prev_dir" HEAD~1

            curr_drvs=$(get_all_drvs ".")
            prev_drvs=$(get_all_drvs "$prev_dir")

            git worktree remove --force "$prev_dir"

            changed_x86=()
            for host in ${l.concatStringsSep " " x86Hosts}; do
              curr=$(echo "$curr_drvs" | jq -r --arg h "$host" '.[$h] // "UNKNOWN_CURR"')
              prev=$(echo "$prev_drvs" | jq -r --arg h "$host" '.[$h] // "UNKNOWN_PREV"')
              if [[ "$curr" != "$prev" ]]; then
                changed_x86+=("$host")
              fi
            done

            changed_arm=()
            for host in ${l.concatStringsSep " " armHosts}; do
              curr=$(echo "$curr_drvs" | jq -r --arg h "$host" '.[$h] // "UNKNOWN_CURR"')
              prev=$(echo "$prev_drvs" | jq -r --arg h "$host" '.[$h] // "UNKNOWN_PREV"')
              if [[ "$curr" != "$prev" ]]; then
                changed_arm+=("$host")
              fi
            done

            if [[ ''${#changed_x86[@]} -gt 0 ]]; then
              x86_json=$(printf '%s\n' "''${changed_x86[@]}" | jq -R . | jq -sc .)
            else
              x86_json="[]"
            fi

            if [[ ''${#changed_arm[@]} -gt 0 ]]; then
              arm_json=$(printf '%s\n' "''${changed_arm[@]}" | jq -R . | jq -sc .)
            else
              arm_json="[]"
            fi
          else
            x86_json='${builtins.toJSON x86Hosts}'
            arm_json='${builtins.toJSON armHosts}'
          fi

          echo "x86_hosts=$x86_json"
          echo "arm_hosts=$arm_json"
        '';
      };

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
          detectChanges = {
            name = "Detect changed hosts";
            "runs-on" = "ubuntu-latest";
            outputs = {
              x86_hosts = "\${{ steps.detect.outputs.x86_hosts }}";
              arm_hosts = "\${{ steps.detect.outputs.arm_hosts }}";
            };
            steps = setup ++ [{
              id = "detect";
              name = "Detect changed hosts";
              run = ''
                nix run .#detect-changes --accept-flake-config >> "$GITHUB_OUTPUT"
              '';
            }];
          };

          buildX86System = {
            name = "Build system (x86)";
            "runs-on" = "ubuntu-latest";
            needs = [ "detectChanges" ];
            "if" = "needs.detectChanges.outputs.x86_hosts != '[]'";
            strategy.matrix.host =
              "\${{ fromJson(needs.detectChanges.outputs.x86_hosts) }}";
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
            needs = [ "detectChanges" ];
            "if" = "needs.detectChanges.outputs.arm_hosts != '[]'";
            strategy.matrix.host =
              "\${{ fromJson(needs.detectChanges.outputs.arm_hosts) }}";
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
        detect-changes = {
          type = "app";
          program = "${detectChanges}/bin/detect-changes";
        };
      };
    };
}
