{ lib, ... }: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
      host all all 100.0.0.0/8 trust
    '';
  };

  services.postgresqlBackup = {
    enable = true;
    databases = lib.mkDefault
      [ ]; # Set individually so the service produces individual SQL files
    startAt = "*-*-* 00:15:00";
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
