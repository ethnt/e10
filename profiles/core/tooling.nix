{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    comma
    htop
    nix-index
    tmux
    mariadb-client
    dosfstools
    gptfdisk
    iputils
    usbutils
    utillinux
  ];
}
