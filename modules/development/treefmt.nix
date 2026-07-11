{ inputs, ... }: {
  imports = [ inputs.treefmt.flakeModule ];

  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      settings = {
        projectRootFile = "flake.nix";
        programs = {
          actionlint.enable = true;
          beautysh.enable = true;
          deadnix.enable = true;
          terraform.enable = true;
          nixfmt.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
          prettier.enable = true;
        };
        settings.formatter = {
          prettier.excludes = [
            ".github/workflows/*.yml"
            "secrets.json"
            "**/secrets.json"
            "**/secrets.yml"
          ];
          nixfmt.excludes = [ "modules/packages/**/*.nix" ];
          nixpkgs-fmt.includes = lib.mkOverride 10 [ "modules/packages/**/*.nix" ];
        };
      };
    in
    {
      treefmt = {
        config = settings;
      };

      formatter = inputs.treefmt.lib.mkWrapper pkgs settings;

      devShells.treefmt = pkgs.mkShell {
        nativeBuildInputs = [
          config.treefmt.build.wrapper
        ]
        ++ (builtins.attrValues config.treefmt.build.programs);
      };
    };
}
