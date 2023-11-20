{
  perSystem = { config, pkgs, ... }: {
    devenv.shells.default.packages = with pkgs; [ ansible cacert ];
  };
}
