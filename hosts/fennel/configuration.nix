{ suites, ... }: {
  imports = with suites; minimal ++ incus-virtual-machine;

  deployment = {
    targetHost = "192.168.1.254";
    deployable = true;
    buildOnTarget = false;
  };

  system.stateVersion = "25.05";
}
