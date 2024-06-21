{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { pkgs, ... }: {
    overlayAttrs = { blocky = pkgs.callPackage ./blocky.nix { }; };
  };
}
