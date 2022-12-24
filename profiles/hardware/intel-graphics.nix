{ pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.kernelModules = [ "i915" ];

  environment.variables.VDPAU_DRIVER = "va_gl";

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      libvdpau-va-gl
      vaapiIntel
    ];
  };
}
