{ pkgs, ... }: {
  services.xteve = {
    enable = true;
    openFirewall = true;
  };

  # Makes ffmpeg available globally (and to xTeVe)
  environment.systemPackages = with pkgs; [ ffmpeg ];
}
