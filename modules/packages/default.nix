_: {
  perSystem = { pkgs, ... }: {
    packages = {
      bichon = pkgs.callPackage ./bichon { };
      declutarr = pkgs.callPackage ./declutarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      tracearr = pkgs.callPackage ./tracearr { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
    };
  };
}
