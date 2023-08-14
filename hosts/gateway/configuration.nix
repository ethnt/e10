{ config, lib, pkgs, profiles, suites, ... }: {
  imports = suites.core ++ [ profiles.virtualisation.aws ];

  e10 = {
    name = "gateway";
    privateAddress = "100.119.226.120";
    publicAddress = "3.137.179.105";
    domain = "gateway.e10.camp";
  };

  system.stateVersion = "23.05";
}
