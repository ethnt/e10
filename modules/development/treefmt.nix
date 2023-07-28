{ inputs, ... }: {
  perSystem = { pkgs, ... }:
    let
      settings = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;

          terraform.enable = true;
        };
      };
    in {
      treefmt = { config = settings; };

      formatter = inputs.treefmt.lib.mkWrapper pkgs settings;
    };
}
