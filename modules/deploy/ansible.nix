{
  perSystem = { pkgs, ... }: {
    devenv.shells.default = {
      packages = with pkgs; [ ansible ansible-lint ];
      enterShell = ''
        export ANSIBLE_ROLES_PATH="$DEVENV_ROOT/deploy/ansible/roles"
      '';
    };
  };
}
