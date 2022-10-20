{ modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];

  services.qemuGuest.enable = true;
}
