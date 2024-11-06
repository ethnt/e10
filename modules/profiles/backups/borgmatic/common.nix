{ config, lib, pkgs, hosts, ... }: {
  sops.secrets = {
    borg_backup_passphrase = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
      owner = "borgmatic";
    };

    rsync_net_ssh_key = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
      owner = "borgmatic";
    };

    apprise_url_ses = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0777";
      owner = "borgmatic";
    };
  };

  users = {
    users.borgmatic = {
      isSystemUser = true;
      group = config.users.groups.borgmatic.name;
      home = "/var/lib/borgmatic";
      createHome = true;
    };

    groups.borgmatic = { };
  };

  programs.ssh.knownHosts."de2228.rsync.net".publicKeyFile = ./key.pub;

  services.borgmatic = {
    enable = true;
    timer = {
      enable = true;
      calendar = "*-*-* 03:00:00";
    };
    configuration = {
      encryption_passcommand = "${
          lib.getExe' pkgs.coreutils "cat"
        } ${config.sops.secrets.borg_backup_passphrase.path}";
      compression = "auto,lzma";
      ssh_command = "ssh -i ${config.sops.secrets.rsync_net_ssh_key.path}";
      before_backup = [
        "${
          lib.getExe' pkgs.borgmatic "borgmatic"
        } rcreate --encryption repokey-blake2"
      ];
      remote_path = "/usr/local/bin/borg1/borg1";
      loki = {
        url = "http://${hosts.monitor.config.networking.hostName}:${
            toString
            hosts.monitor.config.services.loki.configuration.server.http_listen_port
          }/loki/api/v1/push";
        labels = {
          application = "borgmatic";
          host = "__hostname";
          config = "__config";
        };
      };
      on_error = [''
        ${lib.getExe pkgs.apprise} \
          --title "[E10] Backup failed for ${config.networking.hostName}" \
          --body "Backup failed for ${config.networking.hostName} on {repository}" \
          $(cat ${config.sops.secrets.apprise_url_ses.path})
      ''];
    };
  };
}
