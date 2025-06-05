{
  perSystem = { config, pkgs, ... }: {
    packages = {
      tf = pkgs.writeShellScriptBin "tf" ''
        set -euo pipefail

        DIR=$(git rev-parse --show-toplevel)/deploy/terraform

        ${pkgs.lib.getExe pkgs.terraform} -chdir=$DIR "$@"
      '';
    };

    devShells.terraform = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [ config.packages.tf pkgs.terraform ];
    };
  };
}
