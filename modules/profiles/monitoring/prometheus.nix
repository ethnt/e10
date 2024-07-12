{ config, ... }: {
  services.prometheus = {
    enable = true;

    # Thanos stores long term metrics
    retentionTime = "1d";

    extraFlags = [
      "--web.enable-admin-api"
      "--storage.tsdb.min-block-duration=2h"
      "--storage.tsdb.max-block-duration=2h"
    ];

    globalConfig.external_labels.prometheus = "${config.networking.hostName}";
  };

  e10.services.backup.jobs.system.exclude = [ "/var/lib/prometheus2/data/wal" ];
}
