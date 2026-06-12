_: {
  perSystem = { pkgs, ... }: {
    packages = {
      declutarr = pkgs.callPackage ./declutarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      mongodb-ce-6_0 = pkgs.callPackage ./mongodb-ce-6_0 { };
      tracearr = pkgs.callPackage ./tracearr { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
    };
  };
}
