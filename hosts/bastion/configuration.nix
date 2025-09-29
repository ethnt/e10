{ suites, profiles, ... }: {
  imports = with suites; core ++ aws ++ web;

  deployment.buildOnTarget = false;

  system.stateVersion = "25.05";
}
