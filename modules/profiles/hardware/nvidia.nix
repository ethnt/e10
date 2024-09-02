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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    nvidiaPersistenced = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

  # Even though we're not using xserver, this is required to load the driver
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker.enableNvidia = true;
}
