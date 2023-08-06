{ inputs, ... }: {
  perSystem = { config, pkgs, system, ... }: {
    devShells = {
      default = pkgs.mkShellNoCC {
        name = "e10";
        packages = with pkgs;
          [ config.treefmt.build.wrapper ]
          ++ (builtins.attrValues config.treefmt.build.programs);
      } // {
        containers = pkgs.lib.mkForce { };
      };
    };
  };
}
