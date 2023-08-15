{ self, withSystem, ... }:
let
  inherit (self) inputs;
  inherit (inputs) haumea;
  inherit (self.lib.utils) flattenTree;
  l = inputs.nixpkgs.lib // builtins;

  profiles = haumea.lib.load {
    src = ../modules/profiles;
    loader = haumea.lib.loaders.path;
  };

  nixosModules = l.attrValues (flattenTree (haumea.lib.load {
    src = ../modules/nixos;
    loader = haumea.lib.loaders.path;
  }));

  commonModules = [ inputs.sops-nix.nixosModules.sops ] ++ nixosModules;

  suites = import ../modules/suites.nix { inherit profiles; };

  mkHost = hostname:
    { system, extraModules ? [ ]
    , configuration ? ./${hostname}/configuration.nix, ... }:
    withSystem system ({ pkgs, ... }:
      let
        modules = commonModules ++ extraModules ++ [
          configuration
          {
            nixpkgs = { inherit pkgs; };
            networking.hostName = hostname;
          }
        ];

        specialArgs = { inherit profiles suites; };
      in l.nixosSystem { inherit specialArgs modules system; });

in {
  flake.nixosConfigurations = {
    gateway = mkHost "gateway" { system = "x86_64-linux"; };
  };
}
