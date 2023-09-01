{ config, ... }:
let
  username = "de2228";
  hostname = "de2228.rsync.net";
in {
  sops.secrets = {
    borg_backup_passphrase = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
    };

    rsync_net_ssh_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
    };
  };

  e10.services.backup = {
    enable = true;

    inherit username hostname;

    publicKeyFile = ./key.pub;
    privateKeyFile = config.sops.secrets.rsync_net_ssh_key.path;
    passphraseFile = config.sops.secrets.borg_backup_passphrase.path;
  };
}
