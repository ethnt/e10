{ config, lib, ... }: {
  imports = [ ./common.nix ];

  services.borgmatic.configurations.system.repositories = lib.mkAfter [{
    label = "rsync.net";
    path =
      "ssh://de2228@de2228.rsync.net/./${config.networking.hostName}-system";
  }];
}
