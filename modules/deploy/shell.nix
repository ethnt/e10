{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { config, pkgs, inputs', self', ... }: {
    devenv.shells.default = let
      sshConfig = let
        hostConfigurations = l.concatStringsSep "\n" (l.attrValues (l.mapAttrs
          (name: configuration: ''
            Host ${name}
              Hostname ${configuration.config.e10.domain}
          '') self.nixosConfigurations));
      in pkgs.writeText "ssh_config" ''
        ${hostConfigurations}

        Host *
          User root
          IdentityFile keys/id_rsa
      '';

      e10-ssh = pkgs.writeShellScriptBin "e10-ssh" ''
        ssh -F ${sshConfig} $@
      '';
    in _: {
      env.SSH_CONFIG_FILE = sshConfig;
      packages = with inputs'; [ colmena.packages.colmena e10-ssh ];
    };
  };
}
