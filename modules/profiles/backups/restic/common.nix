{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops = {
    secrets = {
      restic_backup_password = {
        sopsFile = ./secrets.yml;
        format = "yaml";
        mode = "0600";
      };

      restic_rest_omnibus_e10_password = {
        sopsFile = ./secrets.yml;
        format = "yaml";
        mode = "0600";
      };

      rsync_net_ssh_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        mode = "0600";
      };

      apprise_url_ses = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        mode = "0777";
      };

      healthchecks_ping_key = {
        format = "yaml";
        sopsFile = ./secrets.yml;
        mode = "0600";
      };
    };

    templates = {
      omnibus_rest_server_environment_file = {
        content = ''
          RESTIC_REST_USERNAME=e10
          RESTIC_REST_PASSWORD=${config.sops.placeholder.restic_rest_omnibus_e10_password}
        '';
      };
    };
  };

  programs.ssh = {
    knownHosts."de2228.rsync.net".publicKeyFile = ./key.pub;
    extraConfig = ''
      Host de2228.rsync.net
        User de2228
        IdentityFile ${config.sops.secrets.rsync_net_ssh_key.path}
    '';
  };

  systemd.services =
    (lib.mapAttrs' (
      name: _:
      lib.nameValuePair "restic-notify-success-${name}" {
        description = "Ping Healthchecks on Restic backup success for ${name}";
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            let
              script = pkgs.writeShellApplication {
                name = "restic-notify-success";
                runtimeInputs = with pkgs; [ curl ];
                text = ''
                  curl -fsS -m 10 --retry 3 \
                    "https://healthchecks.e10.camp/ping/$(cat ${config.sops.secrets.healthchecks_ping_key.path})/${config.networking.hostName}-${name}"
                '';
              };
            in
            "${script}/bin/restic-notify-success";
        };
      }
    ) config.services.restic.backups)
    // {
      "restic-notify-failure@" = {
        description = "Notify on Restic backup failure for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellApplication {
            name = "restic-notify-failure";
            runtimeInputs = with pkgs; [ apprise ];
            text = ''
              apprise \
                --title "[E10] Backup failed for ${config.networking.hostName}" \
                --body "Backup failed for ${config.networking.hostName}: %i" \
                "$(cat ${config.sops.secrets.apprise_url_ses.path})"
            '';
          };
        };
      };
    }
    // lib.mapAttrs' (
      name: _:
      lib.nameValuePair "restic-backups-${name}" {
        unitConfig = {
          OnFailure = "restic-notify-failure@%n.service";
          OnSuccess = "restic-notify-success-${name}.service";
        };
      }
    ) config.services.restic.backups;
}
