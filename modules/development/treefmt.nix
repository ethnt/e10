{ inputs, ... }: {
  perSystem = { config, pkgs, ... }:
    let
      settings = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          terraform.enable = true;
          dhall.enable = true;
        };
      };
    in {
      treefmt = { config = settings; };

      formatter = inputs.treefmt.lib.mkWrapper pkgs settings;

      devenv.shells.default.packages = with pkgs;
        [ config.treefmt.build.wrapper ]
        ++ (builtins.attrValues config.treefmt.build.programs);
    };
}
