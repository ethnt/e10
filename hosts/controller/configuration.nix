{ suites, profiles, ... }: {
  imports = with suites;
    core ++ [
      profiles.power.server.apc
      profiles.networking.unifi
      profiles.networking.blocky
      profiles.filesystems.hybrid-boot
      profiles.filesystems.zfs
      profiles.hardware.intel
      profiles.hardware.hidpi
      profiles.hardware.ssd
      profiles.hardware.thermald
      profiles.databases.redis.blocky
      profiles.databases.postgresql.default
      profiles.databases.postgresql.blocky
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

  e10 = {
    name = "controller";
    privateAddress = "192.168.1.201";
    publicAddress = "192.168.1.201";
    domain = "controller";
  };

  networking.interfaces.eno1 = {
    name = "eno1";
    useDHCP = true;
  };

  system.stateVersion = "23.11";
}
