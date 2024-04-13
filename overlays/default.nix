{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem = { pkgs, ... }: {
    overlayAttrs = {
      # btop = pkgs.btop.overrideAttrs (oldAttrs: {
      #   nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ])
      #     ++ [ pkgs.addOpenGLRunpath ];
      #   postFixup = ''
      #     addOpenGLRunpath $out/bin/btop
      #   '';
      # });

      # blocky = pkgs.callPackage "${pkgs.path}/pkgs/applications/networking/blocky" {
      #   buildGoModule = args:
      #     pkgs.buildGoModule (args // rec {
      #       version = "0.23";

      #       src = pkgs.fetchFromGitHub {
      #         owner = "0xERR0R";
      #         repo = "blocky";
      #         rev = "v${version}";
      #         hash = "sha256-IB5vi+nFXbV94YFtY2eMKTgzUgX8q8i8soSrso2zaD4=";
      #       };

      #       vendorHash = "sha256-h1CkvI7M1kt2Ix3D8+gDl97CFElV+0/9Eram1burOaM=";
      #     });
      # };
      blocky = pkgs.callPackage ./blocky.nix { };
    };
  };
}
