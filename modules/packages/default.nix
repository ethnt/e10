{
  perSystem = { pkgs, ... }: {
    packages = {
      decluttarr = pkgs.callPackage ./decluttarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      incus-apply = pkgs.callPackage ./incus-apply { };
      mazanoke = pkgs.callPackage ./mazanoke { };
      profilarr = pkgs.callPackage ./profilarr { };
      profilarr-parser = pkgs.callPackage ./profilarr-parser { };
      tracearr = pkgs.callPackage ./tracearr { };
      tunarr = pkgs.callPackage ./tunarr { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
      wizarr = pkgs.callPackage ./wizarr { };
    };
  };
}
