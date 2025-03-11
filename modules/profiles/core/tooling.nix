{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    autojump
    bat
    bind
    btop
    comma
    dust
    glances
    inetutils
    iperf3
    lm_sensors
    lnav
    ripgrep
    tmux
    tree
    vim
  ];

  programs.htop.enable = true;
  programs.mtr.enable = true;
}
