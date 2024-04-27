{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U fish_prompt_pwd_dir_length 0
      set -U fish_color_autosuggestion 555 brblack

      function fish_greeting
      end
    '';
  };
}
