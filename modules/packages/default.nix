_: {
  perSystem = { pkgs, ... }: {
    packages = {
      bentopdf = pkgs.callPackage ./bentopdf { };
      fileflows = pkgs.callPackage ./fileflows { };
      mongodb-ce-6_0 = pkgs.callPackage ./mongodb-ce-6_0 { };
      eufy-security-ws = pkgs.callPackage ./eufy-security-ws { };
    };
  };
}
