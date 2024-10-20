_: {
  perSystem = { pkgs, ... }: {
    packages = {
      overseerr = pkgs.callPackage ./overseerr { };
      mongodb-ce-6_0 = pkgs.callPackage ./mongodb-ce-6_0 { };
    };
  };
}
