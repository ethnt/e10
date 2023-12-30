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
    gateway = { tags = [ "aws" "web" ]; };
    monitor = { tags = [ "aws" "web" ]; };
    omnibus = { tags = [ "local" "vm" ]; };
    htpc = { tags = [ "local" "vm" ]; };
    matrix = { tags = [ "local" "vm" ]; };
    controller = { tags = [ "local" "web" ]; };
    builder = { tags = [ "local" "vm" ]; };
  };
}
