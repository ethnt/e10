_: {
  perSystem = { pkgs, ... }: {
    packages = {
      bichon = pkgs.callPackage ./bichon { };
      prometheus-plex-exporter =
        pkgs.callPackage ./prometheus-plex-exporter { };
      declutarr = pkgs.callPackage ./declutarr { };
      fileflows = pkgs.callPackage ./fileflows { };
      mazanoke = pkgs.callPackage ./mazanoke { };
      tracearr = pkgs.callPackage ./tracearr { };
      profilarr = pkgs.callPackage ./profilarr { };
      profilarr-parser = pkgs.callPackage ./profilarr-parser { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
    };
  };
}
