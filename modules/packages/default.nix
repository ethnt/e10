_: {
  perSystem = { pkgs, ... }: {
    packages = { overseerr = pkgs.callPackage ./overseerr { }; };
  };
}
