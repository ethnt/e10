{ suites, profiles, ... }: {
  imports = with suites;
    core
    ++ [ profiles.hardware.rpi4 profiles.power.apc profiles.networking.unifi ]
    ++ [ ./hardware-configuration.nix ];

  e10 = {
    name = "controller";
    privateAddress = "192.168.1.2";
    publicAddress = "192.168.1.2";
    domain = "controller";
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "23.11";
}
