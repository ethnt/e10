{ inputs, config, lib, ... }:

with lib;

let cfg = config.services.atticd;
in {
  imports = [ inputs.attic.nixosModules.atticd ];

  users.users = mkIf (cfg.user == "atticd") {
    atticd = {
      isSystemUser = true;
      group = cfg.group;
      uid = 3450;
    };
  };

  users.groups = mkIf (cfg.group == "atticd") { atticd.gid = 3450; };

  systemd.services.atticd.serviceConfig = mkIf (cfg.enable
    && cfg.settings.storage.type == "local" && cfg.settings.storage.path
    != "/var/lib/atticd/storage") {
      ReadWritePaths = cfg.settings.storage.path;
    };
}
