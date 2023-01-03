{ pkgs, ... }: {
  boot.initrd.kernelModules = [ "i915" ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ intel-compute-runtime intel-media-driver ];
  };

  environment.systemPackages = with pkgs; [ libva-utils ];
}
