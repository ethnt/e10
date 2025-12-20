{ config, lib, ... }: {
  imports = [ ./common.nix ];

  services.borgmatic.configurations.system.repositories = lib.mkAfter [{
    label = "omnibus";
    path = "/mnt/files/backup/${config.networking.hostName}-system";
  }];
}
