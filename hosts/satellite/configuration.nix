{ profiles, suites, lib, ... }: {
  imports = with suites;
    core ++ [ ./hardware-configuration.nix ] ++ [
      profiles.hardware.rpi4
      profiles.virtualisation.docker
      profiles.services.homebridge
      profiles.power.lawsonnet
      profiles.telemetry.prometheus-nut-exporter
      profiles.telemetry.prometheus-smokeping-exporter
      profiles.telemetry.prometheus-unpoller-exporter.lawsonnet
    ];

  deployment = {
    buildOnTarget = false;
    tags = [ "@remote" ];
  };

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };

    nameservers = [ "192.168.1.1" ];

    interfaces = {
      end0.ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.tailscale.extraUpFlags =
    lib.mkAfter [ "--advertise-exit-node" "--advertise-routes=192.168.0.0/16" ];

  system.stateVersion = "23.11";
}
