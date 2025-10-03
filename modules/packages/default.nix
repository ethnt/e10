_: {
  perSystem = { pkgs, ... }: {
    packages = { mongodb-ce-6_0 = pkgs.callPackage ./mongodb-ce-6_0 { }; };
  };
}
