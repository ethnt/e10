{ pkgs, nixosConfigurations, ... }:
let
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
''
