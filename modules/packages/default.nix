{
  perSystem = { pkgs, ... }: {
    packages = rec {
      decluttarr = pkgs.callPackage ./decluttarr { };
      faster-whisper-medium = pkgs.callPackage ./faster-whisper-medium { };
      fileflows = pkgs.callPackage ./fileflows { };
      incus-apply = pkgs.callPackage ./incus-apply { };
      mazanoke = pkgs.callPackage ./mazanoke { };
      profilarr = pkgs.callPackage ./profilarr { };
      profilarr-parser = pkgs.callPackage ./profilarr-parser { };
      stable-ts-whisperless = pkgs.python3Packages.callPackage ./stable-ts-whisperless { };
      subgen = pkgs.callPackage ./subgen {
        inherit stable-ts-whisperless;
        # Choose only capabilities matching GPU on target host (whirlwind)
        cudaCapabilities = [ "8.9" ];
        cudnnSupport = true;
      };
      tracearr = pkgs.callPackage ./tracearr { };
      tunarr = pkgs.callPackage ./tunarr { };
      unifi-os-server-image = pkgs.callPackage ./unifi-os-server-image { };
      wizarr = pkgs.callPackage ./wizarr { };
    };
  };
}
