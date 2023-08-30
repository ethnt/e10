{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    lshw
    glxinfo
    pciutils
    cudatoolkit
    linuxPackages.nvidia_x11
    nvtop
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    modesetting.enable = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
  };

  # Even though we're not using xserver, this is required to load the driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
}
