{ profiles, ... }: {
  imports = [ profiles.filesystems.files.services ];

  services.bichon = {
    enable = true;
    dataDir = "/mnt/files/services/bichon";
    openFirewall = true;
  };
}
