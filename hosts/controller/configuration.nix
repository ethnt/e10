{ lib, suites, profiles, ... }: {
  imports = with suites;
    core ++ [
      profiles.databases.postgresql.blocky
      profiles.databases.postgresql.default
      profiles.databases.redis.blocky
      profiles.filesystems.hybrid-boot
      profiles.filesystems.zfs
      profiles.hardware.hidpi
      profiles.hardware.intel
      profiles.hardware.ssd
      profiles.hardware.thermald
      profiles.networking.blocky
      profiles.networking.tailscale.exit-node
      profiles.networking.unifi
      profiles.power.server.apc
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
    ] ++ [ ./disk-config.nix ./hardware-configuration.nix ];

  e10 = {
    name = "controller";
    privateAddress = "192.168.1.201";
    domain = "controller";
  };

  networking.interfaces.eno1 = {
    name = "eno1";
    useDHCP = true;
  };

  system.stateVersion = "23.11";
}
