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

  # https://github.com/zhaofengli/colmena/issues/60#issuecomment-1047199551
  extraModules = with inputs; [
    colmena.nixosModules.assertionModule
    colmena.nixosModules.keyChownModule
    colmena.nixosModules.deploymentOptions
  ];

  suites = import ../modules/suites.nix { inherit profiles; };

  mkHost = hostname:
    { system, configuration ? ./${hostname}/configuration.nix, ... }:
    withSystem system (_:
      let
        baseConfiguration = _: { networking.hostName = hostname; };
        modules = commonModules ++ [ baseConfiguration configuration ];
        specialArgs = {
          inherit inputs profiles suites;
          flake = self;
          hosts = self.nixosConfigurations;
        };
      in l.nixosSystem { inherit specialArgs modules system extraModules; });

in {
  flake.nixosConfigurations = {
    gateway = mkHost "gateway" { system = "x86_64-linux"; };
    monitor = mkHost "monitor" { system = "x86_64-linux"; };
    omnibus = mkHost "omnibus" { system = "x86_64-linux"; };
    htpc = mkHost "htpc" { system = "x86_64-linux"; };
    matrix = mkHost "matrix" { system = "x86_64-linux"; };
    controller = mkHost "controller" { system = "x86_64-linux"; };
    builder = mkHost "builder" { system = "x86_64-linux"; };
    satellite = mkHost "satellite" { system = "aarch64-linux"; };
    sidecar = mkHost "sidecar" { system = "x86_64-linux"; };
  };
}
