{ pkgs, ... }: {
  boot.initrd.kernelModules = [ "i915" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-compute-runtime intel-media-driver ];
  };

  environment.systemPackages = with pkgs; [ libva-utils intel-gpu-tools ];

  services.xserver.videoDrivers = [ "intel" ];
}
