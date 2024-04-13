{ inputs, ... }: {
  imports = [ inputs.flake-root.flakeModule ];

  perSystem = { config, lib, ... }: {
    devenv.shells.default.enterShell = ''
      export FLAKE_ROOT="$(${lib.getExe config.flake-root.package})"
    '';
  };
}
