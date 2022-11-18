{ config, pkgs, ... }:
let
  username = "de2228";
  hostname = "de2228.rsync.net";
in {
  sops.secrets = {
    borg_backup_passphrase = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
    };
    rsync_net_ssh_key = {
      sopsFile = ./secrets.yaml;
      mode = "0400";
    };
  };

  programs.ssh.knownHosts = { "${hostname}".publicKeyFile = ./key.pub; };

  services.borgbackup.jobs.backup = {
    repo = "${username}@${hostname}:${config.networking.hostName}";
    paths = [ "/var/lib" "/home" "/srv" "/root" ];
    exclude = [
      "/var/lib/docker"
      "/var/lib/systemd"
      "/var/lib/libvirt"
      "'**/.cache'"
      "'**/.nix-profile'"
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets.rsync_net_ssh_key.path}";
    };
    environment.BORG_REMOTE_PATH = "/usr/local/bin/borg1/borg1";
    compression = "auto,lzma";
    startAt = "daily";
    extraArgs = "--remote-path=borg1";
    preHook = ''
      set -x
      eval $(ssh-agent)
      ssh-add ${config.sops.secrets.rsync_net_ssh_key.path}
    '';
  };
}
