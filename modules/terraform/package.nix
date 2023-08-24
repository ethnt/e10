{
  perSystem = { pkgs, ... }:
    let
      tf = pkgs.writeShellScriptBin "tf" ''
        set -euo pipefail

        DIR=$(git rev-parse --show-toplevel)/deploy

        ${pkgs.lib.getExe pkgs.terraform} -chdir=$DIR "$@"
      '';
    in { packages = { inherit tf; }; };
}
