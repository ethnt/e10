{ inputs, pkgs, ... }: {
  imports = [ "${inputs.nixos-hardware}/raspberry-pi/4" ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;

  hardware = {
    enableRedistributableFirmware = true;
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  # console.enable = false;

  environment.systemPackages = with pkgs; [ libraspberrypi raspberrypi-eeprom ];
}
