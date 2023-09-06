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

  commonModules = with inputs;
    [ sops-nix.nixosModules.sops disko.nixosModules.disko ] ++ nixosModules;

  suites = import ../modules/suites.nix { inherit profiles; };

  mkHost = hostname:
    { system, extraModules ? [ ]
    , configuration ? ./${hostname}/configuration.nix, ... }:
    withSystem system ({ pkgs, ... }:
      let
        baseConfiguration = _: {
          nixpkgs = { inherit pkgs; };
          networking.hostName = hostname;
        };
        modules = commonModules ++ extraModules
          ++ [ baseConfiguration configuration ];

        specialArgs = {
          inherit inputs profiles suites;
          hosts = self.nixosConfigurations;
        };
      in l.nixosSystem { inherit specialArgs modules system; });

in {
  flake.nixosConfigurations = {
    gateway = mkHost "gateway" { system = "x86_64-linux"; };
    monitor = mkHost "monitor" { system = "x86_64-linux"; };
    omnibus = mkHost "omnibus" { system = "x86_64-linux"; };
    htpc = mkHost "htpc" { system = "x86_64-linux"; };
    matrix = mkHost "matrix" { system = "x86_64-linux"; };
  };
}
