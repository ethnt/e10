_: {
  perSystem = { pkgs, ... }: {
    packages = {
      bentopdf = pkgs.callPackage ./bentopdf { };
      eufy-security-ws = pkgs.callPackage ./eufy-security-ws { };
      fileflows = pkgs.callPackage ./fileflows { };
      mongodb-ce-6_0 = pkgs.callPackage ./mongodb-ce-6_0 { };
      tracearr = pkgs.callPackage ./tracearr { };
    };
  };
}
