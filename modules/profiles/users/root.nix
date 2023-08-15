{ pkgs, ... }: {
  users.users.root = {
    hashedPassword =
      "$6$uWdBBHFmu2RqXQYG$if2AOX1aSpykA4uzSB//vr0GHt.Kw00tJOHazAnZUEU5LNcIOF6UyMPDSfH97Fis4DJF6kBmUMmqqxXmMn9hp.";
    shell = pkgs.fish;
  };
}
