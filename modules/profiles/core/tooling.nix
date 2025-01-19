{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bat
    btop
    bind
    comma
    dust
    glances
    inetutils
    iperf3
    lm_sensors
    lnav
    tmux
    tree
    vim
  ];

  programs.htop.enable = true;
  programs.mtr.enable = true;
}
