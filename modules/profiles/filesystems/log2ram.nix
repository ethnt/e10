{
  fileSystems."/var/log" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=1G"
    ];
  };
}
