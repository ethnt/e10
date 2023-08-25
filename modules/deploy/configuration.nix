{ self, inputs, ... }:
let
  inherit (self.lib.colmena) mkNode metaFor;
  l = inputs.nixpkgs.lib // builtins;

  configurations = l.removeAttrs self.nixosConfigurations [ ];

  mkNode' = n: mkNode configurations.${n} n;

  mkHive = nodes:
    (l.mapAttrs mkNode' nodes)
    // (metaFor (l.intersectAttrs nodes configurations));
in {
  # TODO: Automatically map `nixosConfigurations`
  flake.colmena = mkHive {
    gateway = { tags = [ "@web" "@aws" ]; };
    monitor = { tags = [ "@web" "@aws" ]; };
    omnibus = { tags = [ "@local" "@vm" ]; };
  };
}
