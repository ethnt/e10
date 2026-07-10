_: {
  perSystem = { pkgs, ... }: {
    packages = {
      bichon = pkgs.callPackage ./bichon { };
      declutarr = pkgs.callPackage ./declutarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      incus-apply = pkgs.callPackage ./incus-apply { };
      mazanoke = pkgs.callPackage ./mazanoke { };
      profilarr = pkgs.callPackage ./profilarr { };
      profilarr-parser = pkgs.callPackage ./profilarr-parser { };
      tracearr = pkgs.callPackage ./tracearr { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
    };
  };
}
