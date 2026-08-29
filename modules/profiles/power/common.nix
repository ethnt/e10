{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.power.ups.upsmon) user group;

  schedulerDirectory = "/run/nut/upssched";

  events = [
    "ONBATT"
    "ONLINE"
    "LOWBATT"
    "COMMBAD"
    "COMMOK"
  ];

  notifyScript = pkgs.writeShellApplication {
    name = "nut-notify-ntfy";
    runtimeInputs = with pkgs; [
      coreutils
      curl
    ];
    text = ''
      event="''${1:-unknown}"

      case "$event" in
        ONBATT)
          message="Running on battery power."
          priority="high"
          tags="warning"
          ;;
        ONLINE)
          message="Back on utility power."
          priority="default"
          tags="white_check_mark"
          ;;
        LOWBATT)
          message="Battery is low; shutdown is imminent."
          priority="urgent"
          tags="rotating_light"
          ;;
        COMMBAD)
          message="Lost communication with the UPS."
          priority="high"
          tags="warning"
          ;;
        COMMOK)
          message="Communication with the UPS restored."
          priority="default"
          tags="white_check_mark"
          ;;
        *)
          message="Unhandled event: $event"
          priority="default"
          tags="grey_question"
          ;;
      esac

      curl \
        --silent \
        --show-error \
        --fail \
        --max-time 10 \
        --retry 2 \
        --user "nut:$(cat ${config.sops.secrets.nut_ntfy_password.path})" \
        --header "Title: [E10] ${config.networking.hostName}/''${UPSNAME:-unknown}: $event" \
        --header "Priority: $priority" \
        --header "Tags: $tags" \
        --header "Content-Type: text/plain" \
        --data-raw "$message" \
        https://ntfy.e10.camp/nut-alerts
    '';
  };

  upsschedConf = pkgs.writeText "upssched.conf" ''
    CMDSCRIPT ${lib.getExe notifyScript}

    PIPEFN ${schedulerDirectory}/upssched.pipe
    LOCKFN ${schedulerDirectory}/upssched.lock

    ${lib.concatLines (map (type: "AT ${type} * EXECUTE ${type}") events)}
  '';
in
{
  sops.secrets = {
    upsmon_password = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
    };

    nut_ntfy_password = {
      format = "yaml";
      sopsFile = ./secrets.yml;
      mode = "0400";
      owner = user;
      inherit group;
    };
  };

  power.ups = {
    enable = true;
    openFirewall = true;
    mode = "netserver";

    upsd = {
      listen = [
        {
          address = "0.0.0.0";
          port = 3493;
        }
      ];
    };

    schedulerRules = toString upsschedConf;

    upsmon.settings.NOTIFYFLAG = map (type: [
      type
      "SYSLOG+EXEC"
    ]) events;

    users = {
      leader = {
        upsmon = "primary";
        passwordFile = config.sops.secrets.upsmon_password.path;
        actions = [
          "SET"
          "FSD"
        ];
        instcmds = [ "ALL" ];
      };

      follower = {
        upsmon = "secondary";
        passwordFile = config.sops.secrets.upsmon_password.path;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${schedulerDirectory} 0700 ${user} ${group} -"
  ];

  # Sometimes a USB device might be mid-reset, so add retries to `upsdrv`
  systemd.services.upsdrv.serviceConfig = {
    Restart = "on-failure";
    RestartSec = 5;
  };
}
