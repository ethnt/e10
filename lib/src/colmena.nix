{ flake, withSystem, ... }:
let l = flake.inputs.nixpkgs.lib // builtins;
in {
  mkNode = evaled: _: settings:
    let
      evaledModules = evaled._module.args.modules;
      defaults = { buildOnTarget = l.mkDefault true; };
      settings' = { deployment = defaults // settings; };
    in { imports = evaledModules ++ [ settings' ]; };

  metaFor = evaled: {
    meta = {
      nixpkgs = withSystem "x86_64-linux" (ctx: ctx.pkgs);
      nodeNixpkgs = l.mapAttrs (_: v: v.pkgs) evaled;
      nodeSpecialArgs = l.mapAttrs (_: v: v._module.specialArgs) evaled;
    };
  };
}
