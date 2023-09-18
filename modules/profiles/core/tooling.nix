{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bind
    busybox
    comma
    glances
    inetutils
    lm_sensors
    tmux
    vim
  ];

  programs.htop.enable = true;
  programs.mtr.enable = true;
}
