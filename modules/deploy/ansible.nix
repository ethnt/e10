{
  perSystem = { config, lib, pkgs, ... }: {
    devenv.shells.default = {
      packages = with pkgs; [ ansible ansible-lint python311Packages.httpx ];

      enterShell = ''
        export ANSIBLE_HOME="$(${
          lib.getExe config.flake-root.package
        })/deploy/ansible";
      '';
    };
  };
}
