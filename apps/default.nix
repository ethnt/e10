{ self, pkgs }: {
  generate-ci = self.inputs.flake-utils.lib.mkApp {
    drv = pkgs.writeShellScriptBin "generate-ci" ''
      ${pkgs.dhall-json}/bin/dhall-to-yaml \
        --file config/ci.dhall \
        --output .github/workflows/ci.yml
    '';
  };

  repl = self.inputs.flake-utils.lib.mkApp {
    drv = pkgs.writeShellScriptBin "repl" ''
      if [ -z "$1" ]; then
        nix repl --argstr host "$(hostname)" --argstr flakePath "${self}" ${
          ./repl.nix
        }
      else
        nix repl --argstr host "$(hostname)" --argstr flakePath $(readlink -f $1 | sed 's|/flake.nix||') ${
          ./repl.nix
        }
      fi
    '';
  };
}
