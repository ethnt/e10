{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    comma
    htop
    inetutils
    lm_sensors
    vim
  ];
}
