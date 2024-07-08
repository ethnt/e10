{ config, inputs, flake, lib, ... }: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      flake.overlays.default
      inputs.proxmox-nixos.overlays.${config.nixpkgs.system}
    ];
  };

  nix = {
    optimise.automatic = true;
    gc.automatic = lib.mkDefault true;

    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

    settings = {
      allowed-users = [ "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
      sandbox = true;
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      trusted-users = [ "root" "@wheel" ];
    };
  };
}
