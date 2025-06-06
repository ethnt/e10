{
  perSystem = { config, lib, pkgs, ... }: {
    devShells.ansible = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        ansible
        ansible-lint
        python311Packages.httpx
      ];

      shellHook = ''
        export ANSIBLE_HOME="$(${
          lib.getExe config.flake-root.package
        })/deploy/ansible";
      '';
    };
  };
}
