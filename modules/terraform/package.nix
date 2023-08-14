{
  perSystem = { pkgs, ... }:
    let
      terraform = pkgs.terraform.withPlugins
        (p: with p; [ aws external local sops tailscale tls ]);

      tf = pkgs.writeShellScriptBin "tf" ''
        set -euo pipefail

        DIR=$(git rev-parse --show-toplevel)/deploy

        ${pkgs.lib.getExe terraform} -chdir=$DIR "$@"
      '';
    in { packages = { inherit terraform tf; }; };
}
