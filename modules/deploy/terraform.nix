{
  perSystem =
    { config, pkgs, ... }:
    let
      tflintWithPlugins = pkgs.tflint.withPlugins (p: [ p.tflint-ruleset-aws ]);
    in
    {
      packages = {
        tf = pkgs.writeShellScriptBin "tf" ''
          set -euo pipefail

          DIR=$(git rev-parse --show-toplevel)/deploy/terraform

          ${pkgs.lib.getExe pkgs.terraform} -chdir=$DIR "$@"
        '';

        tfl = pkgs.writeShellScriptBin "tfl" ''
          DIR=$(git rev-parse --show-toplevel)/deploy/terraform

          ${pkgs.lib.getExe' tflintWithPlugins "tflint"} --chdir=$DIR "$@"
        '';
      };

      devShells.terraform = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          config.packages.tf
          config.packages.tfl
          terraform
          tflintWithPlugins
        ];
      };
    };
}
