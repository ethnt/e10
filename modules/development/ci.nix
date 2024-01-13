{ inputs, ... }: {
  perSystem = { pkgs, system, ... }:
    let
      workflow = {
        name = "CI";
        on.push = { };
        jobs = {
          check = {
            "runs-on" = "ubuntu-latest";
            steps = [
              {
                name = "Checkout code";
                uses = "actions/checkout@v3";
              }
              {
                name = "Install Nix";
                uses = "DeterminateSystems/nix-installer-action@main";
                "with" = {
                  extra-conf = "allow-import-from-derivation = true";
                };
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
              {
                run = ''
                  nix flake check --impure --all-systems --accept-flake-config --show-trace
                '';
              }
            ];
          };
        };
      };
      ci = inputs.nixago.lib.${system}.make {
        data = workflow;
        output = ".github/workflows/ci.yml";
        format = "yaml";
        hook.mode = "copy";
      };
    in {
      apps = {
        generate-ci.program = pkgs.writeShellScriptBin "generate-ci" ''
          ${ci.shellHook}
        '';
      };
    };
}
