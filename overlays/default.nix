{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { pkgs, ... }: {
    overlayAttrs = {
      btop = pkgs.btop.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ])
          ++ [ pkgs.addOpenGLRunpath ];
        postFixup = ''
          addOpenGLRunpath $out/bin/btop
        '';
      });
    };
  };
}
