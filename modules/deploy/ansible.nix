{
  perSystem = { pkgs, ... }: {
    devenv.shells.default.packages = with pkgs; [ ansible ansible-lint ];
  };
}
