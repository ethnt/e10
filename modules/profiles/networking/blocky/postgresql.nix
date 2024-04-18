{ profiles, lib, ... }: {
  imports = [ profiles.databases.postgresql.blocky ];

  services.blocky.settings.queryLog = {
    type = "postgresql";
    target = "postgres://blocky?host=/run/postgresql";
    logRetentionDays = 90;
    flushInterval = "5s";
  };

  systemd.services.blocky = {
    after = [ "postgresql.service" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "1";
    };
  };
}
