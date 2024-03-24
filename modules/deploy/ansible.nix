{
  perSystem = { pkgs, ... }: {
    devenv.shells.default = {
      packages = with pkgs; [ ansible_2_13 ansible-lint ];
      enterShell = let
        ansibleCfg = pkgs.writeText "ansible.cfg" ''
          [defaults]
          strategy_plugins = ${pkgs.python311Packages.mitogen}/lib/python3.11/site-packages/ansible_mitogen/plugins/strategy
          strategy = mitogen_linear
        '';
      in ''
        export ANSIBLE_CONFIG=${ansibleCfg}
      '';
    };
  };
}
