_: {
  perSystem = { pkgs, ... }: {
    packages = {
      declutarr = pkgs.callPackage ./declutarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      tracearr = pkgs.callPackage ./tracearr { };
    };
  };
}
