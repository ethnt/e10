{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
    ./postgresql.nix
  ];

  services.crowdsec.settings = {
    config = {
      api.server = {
        listen_uri = "0.0.0.0:8010";
      };

      prometheus = {
        enabled = true;
        level = "full";
        listen_addr = "0.0.0.0";
        listen_port = 6010;
      };
    };
  };

  systemd.services.crowdsec-github-actions-allowlist = {
    description = "Sync GitHub Actions IP ranges into a CrowdSec allowlist";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "crowdsec.service" ];
    requires = [ "crowdsec.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = config.services.crowdsec.user;
      Group = config.services.crowdsec.group;
      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "crowdsec-github-actions-allowlist";
          runtimeInputs = with pkgs; [
            config.services.crowdsec.package
            coreutils
            curl
            findutils
            jq
          ];
          text = ''
            name=github-actions

            if ! cscli allowlists inspect "$name" >/dev/null 2>&1; then
              cscli allowlists create "$name" --description "GitHub Actions runner IP ranges"
            fi

            desired=$(mktemp)
            current=$(mktemp)
            trap 'rm -f "$desired" "$current"' EXIT

            curl -fsSL --retry 3 https://api.github.com/meta | jq -r '.actions[]' | sort -u >"$desired"

            if [ ! -s "$desired" ]; then
              echo "No GitHub Actions ranges returned" >&2
              exit 1
            fi

            cscli allowlists inspect "$name" -o json | jq -r '.items[]?.value' | sort -u >"$current"

            comm -13 "$current" "$desired" | xargs -r cscli allowlists add "$name" --comment "GitHub Actions"
            comm -23 "$current" "$desired" | xargs -r cscli allowlists remove "$name"
          '';
        }
      );
    };
  };

  systemd.timers.crowdsec-github-actions-allowlist = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnBootSec = "5m";
      RandomizedDelaySec = 300;
      Persistent = true;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    6010
    8010
  ];
}
