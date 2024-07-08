{ lib, ... }: {
  boot = {
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "thunderbolt" "ahci" "nvme" "usbhid" "uas" "sd_mod" ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
