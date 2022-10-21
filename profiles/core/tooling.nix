{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    comma
    htop
    nix-index
    tmux
    dosfstools
    gptfdisk
    iputils
    usbutils
    utillinux
  ];
}
