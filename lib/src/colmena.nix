{ flake, withSystem, ... }:
let l = flake.inputs.nixpkgs.lib // builtins;
in {
  mkNode = evaled: hostname: settings:
    let
      evaledModules = evaled._module.args.modules;
      settings' = { deployment = settings; };
      defaults = { deployment = { buildOnTarget = l.mkDefault true; }; };
    in { imports = evaledModules ++ [ settings' defaults ]; };

  metaFor = evaled: {
    meta = {
      nixpkgs = withSystem "x86_64-linux" (ctx: ctx.pkgs);
      nodeNixpkgs = l.mapAttrs (_: v: v.pkgs) evaled;
      nodeSpecialArgs = l.mapAttrs (_: v: v._module.specialArgs) evaled;
    };
  };
}
