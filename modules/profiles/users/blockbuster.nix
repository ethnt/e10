{ config, ... }: {
  users.groups.blockbuster = {
    name = "blockbuster";
    gid = 1001;
  };

  users.users.blockbuster = {
    name = "blockbuster";
    uid = 1001;
    group = config.users.groups.blockbuster.name;
    isSystemUser = true;
  };
}
