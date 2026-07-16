{ suites, profiles, ... }: {
  imports =
    with suites;
    core
    ++ incus-virtual-machine
    ++ [
      profiles.remote-builder.builder
      profiles.remote-builder.substituter
      profiles.services.attic-watch-store.default
      profiles.services.cachix-watch-store.default
    ];

  deployment = {
    targetHost = "10.10.4.101";
    deployable = true;
    incusVirtualMachine = true;
  };

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "10.10.4.101/24" ];
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "10.10.0.1";
        GatewayOnLink = true;
      }
    ];
    networkConfig.DHCP = "no";
  };

  nix.gc.automatic = false;

  system.stateVersion = "25.05";
}
