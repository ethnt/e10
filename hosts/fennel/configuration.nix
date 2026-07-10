{ suites, ... }: {
  imports = with suites; minimal ++ incus-virtual-machine;

  deployment = {
    targetHost = "10.10.4.101";
    deployable = true;
    incusVirtualMachine = true;
    buildOnTarget = false;
  };

  networking = {
    useDHCP = false;
    nameservers = [ "10.10.0.1" ];
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "10.10.4.101/24" ];
    routes = [{
      routeConfig = {
        Destination = "0.0.0.0/0";
        Gateway = "10.10.0.1";
        GatewayOnLink = true;
      };
    }];
    networkConfig.DHCP = "no";
  };

  system.stateVersion = "25.05";
}
