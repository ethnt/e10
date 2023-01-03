{ pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    video.hidpi.enable = true;
  };

  services.fstrim.enable = true;
}
