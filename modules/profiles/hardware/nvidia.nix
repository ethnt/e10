{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    lshw
    glxinfo
    pciutils
    cudatoolkit
    linuxPackages.nvidia_x11
    nvtopPackages.full
    nvitop
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
  };

  # Even though we're not using xserver, this is required to load the driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
}
