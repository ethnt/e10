{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: {
    packages = { overseerr = pkgs.callPackage ./overseerr { }; };
  };
}
