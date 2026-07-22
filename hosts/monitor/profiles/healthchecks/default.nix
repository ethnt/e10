{
  config,
  hosts,
  lib,
  pkgs,
  ...
}:
let
  backups = lib.pipe hosts [
    (lib.mapAttrs (
      hostname: host:
      lib.mapAttrs' (
        backupName: backup:
        lib.nameValuePair "${hostname}-${backupName}" {
          inherit hostname backupName;
          onCalendar = backup.timerConfig.OnCalendar;
          jitter = backup.timerConfig.RandomizedDelaySec;
        }
      ) host.config.services.restic.backups
    ))
    lib.attrValues
    lib.mergeAttrsList
  ];

  parseDuration =
    s:
    let
      m = builtins.match "([0-9]+)([smhd]?)" s;
      n = lib.toInt (builtins.elemAt m 0);
      unit = builtins.elemAt m 1;
      multiplier =
        {
          "" = 1;
          s = 1;
          m = 60;
          h = 3600;
          d = 86400;
        }
        .${unit};
    in
    n * multiplier;

  toCron =
    onCalendar:
    let
      parts = lib.splitString ":" onCalendar;
    in
    "${lib.elemAt parts 1} ${lib.elemAt parts 0} * * *";

  provisionScript = pkgs.writeShellApplication {
    name = "healthchecks-provision";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      # Wait for Healthchecks to actually be serving requests
      curl -fsS --retry 30 --retry-delay 2 --retry-all-errors --max-time 5 \
        -o /dev/null "https://healthchecks.e10.camp/"
    ''
    + lib.concatMapStringsSep "\n" (
      backup:
      let
        slug = "${backup.hostname}-${backup.backupName}";
        grace = parseDuration backup.jitter * 2 + 3600;
      in
      ''
        curl -fsS -X POST "https://healthchecks.e10.camp/api/v3/checks/" \
          -H "X-Api-Key: $(cat "$CREDENTIALS_DIRECTORY/HEALTHCHECKS_API_KEY")" \
          -H "Content-Type: application/json" \
          -d '{
            "name": "${backup.hostname} / ${backup.backupName}",
            "slug": "${slug}",
            "schedule": "${toCron backup.onCalendar}",
            "tz": "${config.time.timeZone}",
            "grace": ${toString grace},
            "channels": "*",
            "unique": ["slug"]
          }'
      ''
    ) (lib.attrValues backups);
  };
in
{
  sops = {
    secrets = {
      healthchecks_api_key = {
        sopsFile = ./secrets.json;
      };
    };
  };

  services.healthchecks = {
    settings = {
      SITE_ROOT = "https://healthchecks.e10.camp";
      SITE_NAME = "E10";
    };
  };

  systemd.services.healthchecks-provision = {
    description = "Sync Healthchecks checks to Restic backup definitions";
    wantedBy = [ "multi-user.target" ];
    after = [
      "healthchecks.service"
      "caddy.service"
    ];
    restartTriggers = [ (builtins.hashString "sha256" (builtins.toJSON backups)) ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe' provisionScript "healthchecks-provision";
      LoadCredential = [ "HEALTHCHECKS_API_KEY:${config.sops.secrets.healthchecks_api_key.path}" ];
    };
  };
}
