{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    angle-grinder
    btop
    bind
    comma
    glances
    inetutils
    iperf3
    lm_sensors
    lnav
    tmux
    vim
  ];

  programs.htop.enable = true;
  programs.mtr.enable = true;
}
