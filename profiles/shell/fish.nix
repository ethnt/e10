{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U fish_prompt_pwd_dir_length 0

      function fish_greeting
      end
    '';
  };
}
