{
  nix = {
    optimise.automatic = true;
    gc.automatic = true;

    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

    settings = {
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      sandbox = true;
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      trusted-users = [ "root" "@wheel" ];
    };
  };
}
