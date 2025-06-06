{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { config, pkgs, inputs', ... }: {
    devShells.deploy = let
      sshConfig = let
        hostConfigurations = l.concatStringsSep "\n" (l.attrValues (l.mapAttrs
          (name: configuration: ''
            Host ${name}
              Hostname ${configuration.config.deployment.targetHost}
          '') self.nixosConfigurations));
      in pkgs.writeText "ssh_config" ''
        ${hostConfigurations}

        Host *
          User root
          IdentityFile keys/id_rsa
      '';

    in pkgs.mkShell {
      nativeBuildInputs = with inputs'; [
        colmena.packages.colmena
        nixos-anywhere.packages.nixos-anywhere
      ];

      shellHook = ''
        export SSH_CONFIG_FILE=${sshConfig}
      '';
    };
  };
}
