{ config, profiles, ... }: {
  imports = [ profiles.filesystems.files.services ];

  services.bichon = {
    enable = true;
    dataDir = "/mnt/files/services/bichon";
    openFirewall = true;
  };

  provides.bichon = {
    name = "Bichon";
    http = {
      enable = true;
      inherit (config.services.bichon) port;
      domain = "bichon.e10.camp";
    };
  };
}
