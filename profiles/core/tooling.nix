{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    comma
    htop
    dosfstools
    gptfdisk
    iputils
    usbutils
    utillinux
  ];
}
