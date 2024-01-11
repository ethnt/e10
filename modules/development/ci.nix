{
  perSystem = { pkgs, lib, ... }: {
    apps = {
      generate-ci.program = pkgs.writeShellApplication {
        name = "generate-ci";
        text = ''
          cp ${
            pkgs.writeText "ci.yml"
            (builtins.toJSON (import ../../.github/workflows/ci.nix))
          } .github/workflows/ci.yml
        '';
      };
    };
  };
}
