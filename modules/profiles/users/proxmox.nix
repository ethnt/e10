{ config, ... }: {
  users.groups.proxmox = {
    name = "proxmox";
    gid = 1002;
  };

  users.users.proxmox = {
    name = "proxmox";
    uid = 1002;
    group = config.users.groups.proxmox.name;
    hashedPassword =
      "$6$uWdBBHFmu2RqXQYG$if2AOX1aSpykA4uzSB//vr0GHt.Kw00tJOHazAnZUEU5LNcIOF6UyMPDSfH97Fis4DJF6kBmUMmqqxXmMn9hp.";
    isNormalUser = true;
  };
}
