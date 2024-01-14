{ self, inputs, ... }:
let l = inputs.nixpkgs.lib // builtins;
in {
  perSystem = { config, pkgs, inputs', ... }: rec {
    devenv.shells.default = let
      sshConfig = let
        hostConfigurations = l.concatStringsSep "\n" (l.attrValues (l.mapAttrs
          (name: configuration: ''
            Host ${name}
              Hostname ${configuration.config.networking.hostName}
          '') self.nixosConfigurations));
      in pkgs.writeText "ssh_config" ''
        ${hostConfigurations}

        Host *
          User root
          IdentityFile keys/id_rsa
      '';

      ssh = pkgs.lib.getExe' pkgs.openssh "ssh";

      e10-ssh = pkgs.writeShellScriptBin "e10-ssh" ''
        ${ssh} -F ${sshConfig} $@
      '';

      e10-mosh = pkgs.writeShellScriptBin "e10-mosh" ''
        ${pkgs.lib.getExe' pkgs.mosh "mosh"} --ssh="ssh -F ${sshConfig}" $@
      '';

      e10-scp = pkgs.writeShellScriptBin "e10-scp" ''
        ${pkgs.lib.getExe' pkgs.openssh "scp"} -F ${sshConfig} $@
      '';

      e10-rsync = pkgs.writeShellScriptBin "e10-rsync" ''
        ${pkgs.lib.getExe' pkgs.rsync "rsync"} -e "${ssh} -F ${sshConfig}" $@
      '';
    in _: {
      env.SSH_CONFIG_FILE = sshConfig;
      packages = with inputs'; [
        colmena.packages.colmena
        nixos-anywhere.packages.nixos-anywhere
        e10-ssh
        e10-mosh
        e10-scp
        e10-rsync
      ];
    };
  };
}
