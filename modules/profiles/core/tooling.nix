{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    autojump
    bat
    bind
    btop
    comma
    dua
    dust
    glances
    inetutils
    iperf3
    lm_sensors
    lnav
    pciutils
    ripgrep
    tmux
    tree
    vim
  ];

  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.mtr.enable = true;
}
