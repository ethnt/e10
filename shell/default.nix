{ self, pkgs, ... }:

let
  inherit (self) inputs;

  eval = import "${inputs.devshell}/modules" pkgs;

  configuration = {
    name = "camp";
    imports = [ ./camp.nix ];
  };
in (eval {
  inherit configuration;
  extraSpecialArgs = { inherit self inputs; };
}).shell
