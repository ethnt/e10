{ config, lib, pkgs, ... }:

with lib;

let cfg = config.e10.services.backup;
in {
  options.e10.services.backup = {
    enable = mkEnableOption "Enable backup to rsync.net via borgbackup";

    username = mkOption {
      type = types.str;
      description = "Username for rsync.net";
    };

    hostname = mkOption {
      type = types.str;
      description = "Hostname for rsync.net account";
      default = "${cfg.username}.rsync.net";
    };

    publicKeyFile = mkOption {
      type = types.path;
      description = "File with public key for rsync.net server";
    };

    privateKeyFile = mkOption {
      type = types.path;
      description = "File with private key for rsync.net server";
    };

    passphraseFile = mkOption {
      type = types.path;
      description = "File with passphrase for encrypting the backup";
    };

    jobs = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          repoName = mkOption {
            type = types.str;
            description = "Name of the repo on rsync.net";
          };

          paths = mkOption {
            type = types.listOf types.str;
            description = "List of paths to back up";
            default = [ ];
          };

          exclude = mkOption {
            type = types.listOf types.str;
            description = "List of paths to exclude from the back up";
            default = [ ];
          };

          pruneKeep = mkOption {
            type = types.attrsOf types.anything;
            description =
              "Options to pass to `services.borgbackup.jobs.<name>.prune.keep`";
            default = {
              within = "1d";
              daily = 7;
              weekly = 4;
              monthly = -1;
            };
          };

          extraOptions = mkOption {
            type = types.attrs;
            description =
              "Extra options to pass to `services.borgbackup.jobs.<name>`";
            default = { };
          };
        };
      });
    };
    description = "Borg job configuration settings";
    default = { };
  };

  config = mkIf cfg.enable {
    programs.ssh.knownHosts."${cfg.hostname}" = {
      inherit (cfg) publicKeyFile;
    };

    services.borgbackup.jobs = mapAttrs (name: jobConfig:
      {
        inherit (jobConfig) paths exclude;

        repo = "${cfg.username}@${cfg.hostname}:${jobConfig.repoName}";

        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${cfg.passphraseFile}";
        };
        environment.BORG_REMOTE_PATH = "/usr/local/bin/borg1/borg1";
        compression = "auto,lzma";
        startAt = "*-*-* 03:00:00";
        extraArgs = "--remote-path=borg1";
        extraCreateArgs = "--debug --stats";
        prune.keep = jobConfig.pruneKeep;
        preHook = ''
          set -x
          eval $(ssh-agent)
          ssh-add ${cfg.privateKeyFile}
        '';
      } // jobConfig.extraOptions) cfg.jobs;
  };
}
