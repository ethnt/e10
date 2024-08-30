{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = _: { overlayAttrs = { }; };
}
