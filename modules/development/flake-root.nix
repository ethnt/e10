{ inputs, ... }: {
  imports = [ inputs.flake-root.flakeModule ];

  perSystem = { config, lib, pkgs, ... }: {
    devShells.flake-root = pkgs.mkShell {
      shellHook = ''
        export FLAKE_ROOT="$(${lib.getExe config.flake-root.package})"
      '';
    };
  };
}
