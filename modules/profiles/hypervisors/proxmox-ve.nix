{ config, inputs, ... }: {
  nixpkgs.overlays = [ inputs.proxmox-nixos.overlays.${config.nixpkgs.system} ];

  imports = [ inputs.proxmox-nixos.nixosModules.proxmox-ve ];

  services.proxmox-ve.enable = true;
}
