{ pkgs, ... }:
pkgs.writeText "ssh_config" ''
  Host *
    User root
    IdentityFile keys/id_rsa
''
