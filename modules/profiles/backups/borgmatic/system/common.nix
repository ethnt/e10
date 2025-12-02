{
  imports = [ ../common.nix ];

  services.borgmatic.configurations.system = {
    source_directories = [ "/etc" "/var/lib" "/srv" "/root" ];
    exclude_patterns = [
      "**/.cache"
      "**/.nix-profile"
      "/var/lib/containers"
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/postgresql"
      "/var/lib/private"
      "/var/lib/systemd"
      "/var/logs"
    ];
    keep_daily = 3;
    keep_weekly = 2;
    keep_monthly = 2;
  };
}
