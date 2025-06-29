{ inputs, ... }: {
  imports = [ inputs.treefmt.flakeModule ];

  perSystem = { config, pkgs, ... }:
    let
      settings = {
        projectRootFile = "flake.nix";
        programs = {
          deadnix.enable = true;
          terraform.enable = true;
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-classic;
          };
          statix.enable = true;
          prettier.enable = true;
        };
        settings.formatter.prettier.excludes = [
          ".github/workflows/*.yml"
          "secrets.json"
          "**/secrets.json"
          "**/secrets.yml"
        ];
      };
    in {
      treefmt = { config = settings; };

      formatter = inputs.treefmt.lib.mkWrapper pkgs settings;

      devShells.treefmt = pkgs.mkShell {
        nativeBuildInputs = with pkgs;
          [ config.treefmt.build.wrapper ]
          ++ (builtins.attrValues config.treefmt.build.programs);
      };
    };
}
