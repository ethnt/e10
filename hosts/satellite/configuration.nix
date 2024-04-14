{ profiles, suites, lib, ... }: {
  imports = with suites;
    core ++ [ ./hardware-configuration.nix ] ++ [ profiles.hardware.rpi4 ];

  deployment.buildOnTarget = false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.tailscale.extraUpFlags =
    lib.mkAfter [ "--advertise-routes=192.168.0.0/16" ];

  system.stateVersion = "23.11";
}
