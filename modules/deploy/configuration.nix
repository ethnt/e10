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

  # colmena re-evaluates each node with `evalConfig`, applying
  # `meta.nodeNixpkgs.<name>.overlays` on top of the node's own modules (which
  # also declare `nixpkgs.overlays`). Handing it the already-overlaid
  # `configuration.pkgs` therefore applies every overlay twice. For most hosts
  # that is harmless, but the nixos-raspberrypi firmware overlays are not
  # idempotent and a second application causes infinite recursion. For those
  # hosts we hand colmena a *base* (un-overlaid) Nixpkgs from the same source,
  # so the node's modules apply the RPi overlays exactly once.
  nodeNixpkgsFor =
    configuration:
    if (configuration.config.boot.loader.raspberry-pi.enable or false) then
      import configuration.pkgs.path { inherit (configuration.pkgs.stdenv.hostPlatform) system; }
    else
      configuration.pkgs;

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
