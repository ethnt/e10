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
      inherit (config.services.bichon) port;
      proxy = {
        enable = true;
        domain = "bichon.e10.camp";
      };
    };
  };
}
