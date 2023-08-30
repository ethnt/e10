{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
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
