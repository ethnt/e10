{ config, ... }: {
  users.groups.files = {
    name = "files";
    gid = 1010;
  };

  users.users.files = {
    name = "files";
    uid = 1010;
    group = config.users.groups.files.name;
    isSystemUser = true;
  };
}
