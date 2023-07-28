{
  perSystem = { pkgs, ... }:
    let
      terraformPluginsPredicate = p: with p; [ ];
      terraform = pkgs.terraform.withPlugins terraformPluginsPredicate;
    in { packages = { inherit terraform; }; };
}
