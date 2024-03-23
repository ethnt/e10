{
  perSystem = { config, pkgs, ... }: {
    packages = {
      tf = pkgs.writeShellScriptBin "tf" ''
        set -euo pipefail

        DIR=$(git rev-parse --show-toplevel)/deploy/terraform

        ${pkgs.lib.getExe pkgs.terraform} -chdir=$DIR "$@"
      '';
    };

    devenv.shells.default.packages = [ config.packages.tf pkgs.terraform ];
  };
}
