{ self, lib, withSystem, ... }:

with lib;

let
  deployableConfigurations =
    filterAttrs (_: c: c.config.deployment.deployable) self.nixosConfigurations;

  mkColmenaMeta = configurations: {
    meta = {
      nixpkgs = withSystem "x86_64-linux" (ctx: ctx.pkgs);
      nodeNixpkgs =
        mapAttrs (_: configuration: configuration.pkgs) configurations;
      nodeSpecialArgs =
        mapAttrs (_: configuration: configuration._module.specialArgs)
        configurations;
    };
  };

  mkColmenaNodes = configurations:
    (mapAttrs
      (_name: configuration: { imports = configuration._module.args.modules; })
      configurations);

  mkColmenaOutput = configurations:
    (mkColmenaMeta configurations // mkColmenaNodes configurations);

in { flake.colmena = mkColmenaOutput deployableConfigurations; }
