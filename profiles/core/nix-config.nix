{ self, config, lib, ... }: {
  imports = [ ../cachix ];

  nix = {
    autoOptimiseStore = true;
    optimise.automatic = true;
    gc.automatic = true;
    useSandbox = true;
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  };

  system.stateVersion = "22.05";
}
