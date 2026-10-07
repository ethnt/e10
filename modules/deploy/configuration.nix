{
  self,
  lib,
  withSystem,
  inputs,
  ...
}:

with lib;

let
  deployableConfigurations = filterAttrs (
    _: c: c.config.deployment.deployable
  ) self.nixosConfigurations;

  nodeNixpkgsFor =
    configuration:
    import configuration.pkgs.path { inherit (configuration.pkgs.stdenv.hostPlatform) system; };

  mkColmenaMeta = configurations: {
    meta = {
      nixpkgs = withSystem "x86_64-linux" (ctx: ctx.pkgs);
      nodeNixpkgs = mapAttrs (_: nodeNixpkgsFor) configurations;
      nodeSpecialArgs = mapAttrs (_: configuration: configuration._module.specialArgs) configurations;
    };
  };

  mkColmenaNodes =
    configurations:
    (mapAttrs (_name: configuration: { imports = configuration._module.args.modules; }) configurations);

  mkColmenaOutput = configurations: (mkColmenaMeta configurations // mkColmenaNodes configurations);

in
{
  flake = {
    colmena = mkColmenaOutput deployableConfigurations;
    colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;
  };
}
