{
  perSystem = { pkgs, ... }: {
    apps = {
      generate-ci.program = pkgs.writeShellScriptBin "generate-ci" ''
        set -euo pipefail

        ${pkgs.dhall-json}/bin/dhall-to-yaml \
          --file .github/workflows/ci.dhall \
          --output .github/workflows/ci.yml
      '';
    };
  };
}
